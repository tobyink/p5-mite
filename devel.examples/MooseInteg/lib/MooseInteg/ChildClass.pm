package MooseInteg::ChildClass;

use Moose;
use MooseInteg::MOP;

extends 'MooseInteg::BaseClass';
with 'MooseInteg::SomeRole';

has baz => (
	is => 'rw',
	isa => 'HashRef',
);

around number => sub {
	my ( $next, $self ) = ( shift, shift );
	2 + $self->$next( @_ );
};

__PACKAGE__->meta->make_immutable;

1;
