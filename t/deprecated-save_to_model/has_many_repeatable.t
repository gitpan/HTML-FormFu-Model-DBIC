use strict;
use warnings;
use Test::More tests => 8;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-save_to_model/has_many_repeatable.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $master = $schema->resultset('Master')->create({ id => 1 });

# filler rows
{
    # user 1
    my $u1 = $master->create_related( 'user', { name => 'foo' } );

    # address 1
    $u1->create_related( 'addresses' => { address => 'somewhere' } );
}

# rows we're going to use
{
    # user 2
    my $u2 = $master->create_related( 'user', { name => 'nick', } );

    # address 2
    $u2->create_related( 'addresses', { address => 'home' } );

    # address 3
    $u2->create_related( 'addresses', { address => 'office' } );
}

{
    $form->process( {
            'id'                  => 2,
            'name'                => 'new nick',
            'count'               => 2,
            'addresses.id_1'      => 2,
            'addresses.address_1' => 'new home',
            'addresses.id_2'      => 3,
            'addresses.address_2' => 'new office',
        } );

    ok( $form->submitted_and_valid );

    my $row = $schema->resultset('User')->find(2);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->save_to_model($row);
        ok( $warnings, 'warning thrown' );
    }
}

{
    my $user = $schema->resultset('User')->find(2);

    is( $user->name, 'new nick' );

    my @add = $user->addresses->all;

    is( scalar @add, 2 );

    is( $add[0]->id,      2 );
    is( $add[0]->address, 'new home' );

    is( $add[1]->id,      3 );
    is( $add[1]->address, 'new office' );
}

