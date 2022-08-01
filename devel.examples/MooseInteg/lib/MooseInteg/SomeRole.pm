package MooseInteg::SomeRole;

use MooseInteg::Mite -role;

has bar => (
	is => 'rw',
	isa => 'Object',
	handles => [ 'quux' ],
);

around number => sub {
	my ( $next, $self ) = ( shift, shift );
	10 * $self->$next( @_ );
};

1;
