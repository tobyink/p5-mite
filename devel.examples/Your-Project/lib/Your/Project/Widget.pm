package Your::Project::Widget;
use Your::Project::Mite;

has name => (
	is     => 'ro',
	isa    => 'Str',
);

sub upper_case_name {
	my $self = shift;
	return uc( $self->name );
}

1;