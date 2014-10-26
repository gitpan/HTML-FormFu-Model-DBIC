package MySchema::Master;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ 
    InflateColumn::DateTime Core
/);

__PACKAGE__->table("master");

__PACKAGE__->add_columns(
    id             => { data_type => "INTEGER", is_nullable => 0 },
    text_col       => { data_type => "TEXT" },
    password_col   => { data_type => "TEXT" },
    checkbox_col   => {
        data_type => "TEXT",
        default_value => 0,
        is_nullable   => 0,
    },
    select_col     => { data_type => "TEXT" },
    radio_col      => { data_type => "TEXT" },
    radiogroup_col => { data_type => "TEXT" },
    date_col       => { data_type => "DATETIME" },
    type_id        => { data_type => "INTEGER" },
    type2_id       => { data_type => "INTEGER" },
    not_in_form    => { data_type => "TEXT" },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->might_have( note => 'MySchema::Note', 'master' );

__PACKAGE__->has_one( user => 'MySchema::User', 'master' );

__PACKAGE__->has_many( schedules => 'MySchema::Schedule', 'master' );

__PACKAGE__->belongs_to(
    type => 'MySchema::Type',
    { 'foreign.id' => 'self.type_id' } );

__PACKAGE__->belongs_to(
    type2 => 'MySchema::Type2',
    { 'foreign.id' => 'self.type2_id' } );


sub method_test {
    my $self = shift;
    if (@_) {
        $self->text_col(@_);
    }

    return $self->text_col;
}

sub method_select_test {
    my $self = shift;
    if (@_) {
        $self->select_col(@_);
    }

    return $self->select_col;
}

sub method_checkbox_test {
    my $self = shift;
    if (@_) {
        $self->checkbox_col(@_);
    }
    return $self->checkbox_col;
}
1;

