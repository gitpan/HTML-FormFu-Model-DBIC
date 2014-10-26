use strict;
use warnings;
use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-save_to_model/column_without_field.yml');

my $schema = new_schema();

my $rs = $schema->resultset('Master');

{
    my $row = $rs->new_result( {
            text_col     => 'a',
            password_col => 'd',
            checkbox_col => 'g'
        } );

    $row->insert;
}

# Fake submitted form
$form->process( {
        id       => 1,
        text_col => 'abc',
    } );

{
    my $row = $rs->find(1);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->save_to_model($row);
        ok( $warnings, 'warning thrown' );
    }
}

{
    my $row = $rs->find(1);

    is( $row->text_col, 'abc' );

    # original values still there

    is( $row->password_col, 'd' );
    is( $row->checkbox_col, 'g' );
}

