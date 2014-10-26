use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/update/many_to_many_select.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $user_rs = $schema->resultset('User');
my $band_rs = $schema->resultset('Band');

{

    # user 1
    my $u1 = $user_rs->new_result( { name => 'John' } );
    $u1->insert;

    # user 2
    my $u2 = $user_rs->new_result( { name => 'Paul' } );
    $u2->insert;

    # band 1
    my $b1 = $u1->add_to_bands( { band => 'the beatles' } );

    # user 2 => band 2
    $u2->add_to_bands( { band => 'wings' } );

    # band 3
    my $b3 = $band_rs->new_result( { band => 'the kinks' } );
    $b3->insert;

    # user 2 => band 1
    $u2->add_to_bands($b1);
}

# currently,
# user [2] => bands [2, 1]

{
    $form->process( {
            id    => 2,
            name  => 'Paul McCartney',
            # no bands - if you unselect all options,
            # the browser doesn't submit that param at all
        } );

    ok( $form->submitted_and_valid );

    my $row = $user_rs->find(2);

    $form->model->update($row);

    is( $row->name, 'Paul McCartney' );

    my @bands = $row->bands->all;

    is( scalar(@bands), 0 );
}

