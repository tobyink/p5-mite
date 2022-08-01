package MooseInteg::ChildClass;

use Moose;
use MooseInteg::MOP;

extends 'MooseInteg::BaseClass';
with 'MooseInteg::SomeRole';

has baz => (
	is => 'rw',
	isa => 'HashRef',
);

__PACKAGE__->meta->make_immutable( replace_constructor => 1 );

1;
