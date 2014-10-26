use strict;
use warnings;
use Test::More tests => 5;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-defaults_from_model/might_have.yml');

my $schema = new_schema();

my $rs      = $schema->resultset('Master');
my $note_rs = $schema->resultset('Note');

{

    # insert some entries we'll ignore, so our rels don't have same ids
    # test id 1
    my $t1 = $rs->new_result( { text_col => 'xxx' } );
    $t1->insert;

    # test id 2
    my $t2 = $rs->new_result( { text_col => 'yyy' } );
    $t2->insert;

    # note id 1
    my $n1 = $t2->new_related( 'note', { note => 'zzz' } );
    $n1->insert;

    # should get test id 3
    my $master = $rs->new_result( { text_col => 'a', } );
    $master->insert;

    # no note
}

{
    my $row = $rs->find(3);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->defaults_from_model($row);
        ok( $warnings, 'warning thrown' );
    }

    is( $form->get_field('id')->render_data->{value},       3 );
    is( $form->get_field('text_col')->render_data->{value}, 'a' );

    my $block = $form->get_all_element( { nested_name => 'note' } );

    is( $block->get_field('id')->render_data->{value},   undef );
    is( $block->get_field('note')->render_data->{value}, undef );

}

