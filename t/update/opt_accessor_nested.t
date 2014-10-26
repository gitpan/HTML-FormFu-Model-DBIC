use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/update/opt_accessor_nested.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('User');

# filler row

$rs->create( { name => 'foo', } );

# Fake submitted form
$form->process( {
        'foo.id'       => 2,
        'foo.fullname' => 'mr billy bob',
    } );

{
    my $row = $rs->new( {} );

    $form->model->update( $row, { nested_base => 'foo' } );
}

{
    my $row = $rs->find(2);

    is( $row->title,    'mr' );
    is( $row->name,     'billy bob' );
    is( $row->fullname, 'mr billy bob' );
}

