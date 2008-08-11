use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/default_values/nested_base_accessor.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $master = $schema->resultset('Master')->create({ id => 1 });

# filler row

$master->create_related( 'user', { name => 'filler', } );

# row we're going to use

my $row = $master->create_related( 'user', {
        name => 'mr. foo',
    } );

$row->create_related( 'hasmanys', { key => 'bar', value => 'a' } );
$row->create_related( 'hasmanys', { key => 'foo', value => 'b' } );

{
    my $row = $schema->resultset('User')->find(2);

    $form->model->default_values($row);

    is( $form->get_field('name')->default, 'mr. foo' );
    
    is ( $form->get_field('value')->default, 'b' );
}

