package Acme::Mitey::Cards::Card::Numeric;

our $VERSION   = '0.006';
our $AUTHORITY = 'cpan:TOBYINK';

use Acme::Mitey::Cards::Mite qw( -bool -is );
extends 'Acme::Mitey::Cards::Card';

use Acme::Mitey::Cards::Suit;

has suit => (
	is       => ro,
	isa      => 'InstanceOf["Acme::Mitey::Cards::Suit"]',
	required => true,
);

has number => (
	is       => ro,
	isa      => 'Int',
	required => true,
);

sub number_or_a {
	my $self = shift;

	my $num = $self->number;
	( $num == 1 ) ? 'A' : $num;
}

sub to_string {
	my $self = shift;

	return sprintf( '%s%s', $self->number_or_a, $self->suit->abbreviation );
}

1;
