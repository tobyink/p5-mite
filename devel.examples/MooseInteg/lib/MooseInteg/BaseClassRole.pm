package MooseInteg::BaseClassRole;

use MooseInteg::Mite -role;

has xyzzy => (
	is => 'rw',
	isa => 'Int',
);

1;
