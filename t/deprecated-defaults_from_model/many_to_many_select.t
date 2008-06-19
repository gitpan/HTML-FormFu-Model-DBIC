use strict;
use warnings;
use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-defaults_from_model/many_to_many_select.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs      = $schema->resultset('User');
my $band_rs = $schema->resultset('Band');

# filler

{
    $rs->create( { name => 'John', } );

    $rs->create( { name => 'Ringo', } );

    $rs->create( { name => 'George', } );

    $band_rs->create( { band => 'the kinks', } );
}

# row we're going to use

{
    my $paul = $rs->create( { name => 'Paul', } );

    $paul->add_to_bands( { band => 'the beatles', } );

    $paul->add_to_bands( { band => 'wings', } );
}

{
    my $row = $rs->find(4);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->defaults_from_model($row);
        ok( $warnings, 'warning thrown' );
    }

    is( $form->get_field('id')->default,   4 );
    is( $form->get_field('name')->default, 'Paul' );

    is_deeply( $form->get_field('bands')->default, [ 2, 3 ] );
}
