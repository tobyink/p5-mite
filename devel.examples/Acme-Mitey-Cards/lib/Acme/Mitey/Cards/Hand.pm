package Acme::Mitey::Cards::Hand;

our $VERSION   = '0.010';
our $AUTHORITY = 'cpan:TOBYINK';

use Acme::Mitey::Cards::Mite qw( -bool -is );
use Acme::Mitey::Cards::Types qw(:types);

extends 'Acme::Mitey::Cards::Set';

has owner => (
	is       => rw,
	isa      => StringOrObject,
);

1;
