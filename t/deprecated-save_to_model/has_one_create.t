use strict;
use warnings;
use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-save_to_model/has_one.yml');

my $schema = new_schema();

my $rs = $schema->resultset('Master');

# Fake submitted form
$form->process( {
        "id"        => 3,
        "text_col"  => 'a',
        "user.name" => 'bar',
    } );

{

    # insert some entries we'll ignore, so our rels don't have same ids
    # test id 1
    my $t1 = $rs->new_result( { text_col => 'xxx' } );
    $t1->insert;

    # test id 2
    my $t2 = $rs->new_result( { text_col => 'yyy' } );
    $t2->insert;

    # user id 1
    my $n1 = $t2->new_related( 'user', { name => 'zzz' } );
    $n1->insert;

    # should get master id 3
    my $master = $rs->new( { text_col => 'b' } );

    $master->insert;

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->save_to_model($master);
        ok( $warnings, 'warning thrown' );
    }
}

{
    my $row = $rs->find(3);

    is( $row->text_col, 'a' );

    my $user = $row->user;

    is( $user->id,   2 );
    is( $user->name, 'bar' );
}

