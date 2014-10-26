use strict;
use warnings;
use Test::More tests => 10;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/default_values/many_to_many_repeatable.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $master = $schema->resultset('Master')->create({ id => 1 });

# filler

{
    my $user = $master->create_related( 'user', { name => 'filler', } );

    $user->add_to_bands( { band => 'a', } );

    $master->create_related( 'user', { name => 'filler2', } );

    $master->create_related( 'user', { name => 'filler3', } );

    $master->create_related( 'user', { name => 'filler4', } );
}

# row we're going to use

{
    my $user = $master->create_related( 'user', { name => 'nick', } );

    $user->add_to_bands( { band => 'b', } );

    $user->add_to_bands( { band => 'c', } );

    $user->add_to_bands( { band => 'd', } );
}

{
    my $row = $schema->resultset('User')->find(5);

    $form->model->default_values($row);

    is( $form->get_field('id')->default,    '5' );
    is( $form->get_field('name')->default,  'nick' );
    is( $form->get_field('count')->default, '3' );

    my $block = $form->get_all_element( { nested_name => 'bands' } );

    my @reps = @{ $block->get_elements };

    is( scalar @reps, 3 );

    is( $reps[0]->get_field('id')->default,   '2' );
    is( $reps[0]->get_field('band')->default, 'b' );

    is( $reps[1]->get_field('id')->default,   '3' );
    is( $reps[1]->get_field('band')->default, 'c' );

    is( $reps[2]->get_field('id')->default,   '4' );
    is( $reps[2]->get_field('band')->default, 'd' );
}

