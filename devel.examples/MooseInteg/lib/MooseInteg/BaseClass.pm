package MooseInteg::BaseClass;

use MooseInteg::Mite;
with 'MooseInteg::BaseClassRole';

has foo => (
	is => 'rw',
	isa => 'Int',
);

has hashy => (
	is => 'ro',
	isa => 'HashRef[Int]',
	default => {},
	handles_via => 'Hash',
	handles => { '%s_set' => 'set' },
);

sub number {
	my ( $self, @args ) = @_;
	require List::Util;
	return List::Util::sum( @args );
}

1;
