use strict;
use warnings;
use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-save_to_model/might_have.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs      = $schema->resultset('Master');
my $note_rs = $schema->resultset('Note');

# Fake submitted form
$form->process( {
        "id"        => 3,
        "text_col"  => 'a',
        "note.note" => 'abc',
    } );

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
    my $master = $rs->new( { text_col => 'b' } );

    $master->insert;

    # no note, but next id 2

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

    my $note = $row->note;

    is( $note->id,   2 );
    is( $note->note, 'abc' );
}

