package MooseInteg::BaseClass;

use MooseInteg::Mite;

has foo => (
	is => 'rw',
	isa => 'Int',
);

sub number {
	my ( $self, @args ) = @_;
	require List::Util;
	return List::Util::sum( @args );
}

1;
