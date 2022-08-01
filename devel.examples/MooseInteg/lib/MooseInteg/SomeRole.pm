package MooseInteg::SomeRole;

use MooseInteg::Mite -role;

has bar => (
	is => 'rw',
	isa => 'ArrayRef',
);

1;
