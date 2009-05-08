use strict;
use warnings;
use Test::More tests => 9;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/update/has_many_repeatable_new_dependon.yml');

# a form is created with 'empty_rows' => 2
# but only 1 new row is filled in

# test a DependOn constraint attached to the PK column
# with 'others' listing the required fields

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
            'count'               => 4,
            'addresses.id_1'      => 2,
            'addresses.address_1' => 'new home',
            'addresses.id_2'      => 3,
            'addresses.address_2' => 'new office',
            'addresses.id_3'      => '',
            'addresses.address_3' => 'new address',
        } );

    ok( $form->submitted_and_valid );

    my $row = $schema->resultset('User')->find(2);

    $form->model->update($row);
}

{
    my $user = $schema->resultset('User')->find(2);

    is( $user->name, 'new nick' );

    my @add = $user->addresses->all;

    is( scalar @add, 3 );

    is( $add[0]->id,      2 );
    is( $add[0]->address, 'new home' );

    is( $add[1]->id,      3 );
    is( $add[1]->address, 'new office' );

    is( $add[2]->id,      4 );
    is( $add[2]->address, 'new address' );
}

