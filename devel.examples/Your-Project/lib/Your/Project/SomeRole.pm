package Your::Project::SomeRole;
use Your::Project::Mite -role;

around foo => sub {
	my ( $next, $self ) = ( shift, shift );
	return uc( $self->$next( @_ ) );
};

1;