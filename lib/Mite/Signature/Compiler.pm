use 5.010001;
use strict;
use warnings;

package Mite::Signature::Compiler;

use Type::Params::Signature 1.016008 ();
use Types::Standard qw( Slurpy );
use Scalar::Util ();

our @ISA = 'Type::Params::Signature';

sub BUILD {
	my $self = shift;

	Scalar::Util::weaken( $self->{mite_signature} );

	# This is not a Mite class, so manually call
	# parent BUILD:
	$self->SUPER::BUILD( @_ );
}

sub _make_general_fail {
	my ( $self, %args ) = @_;

	my $croaker = $self->{mite_signature}->class->_function_for_croak;

	return sprintf '%s( "Failure in signature for %s: " . %s )', $croaker, $self->subname, $args{message};
}

sub _make_constraint_fail {
	my ( $self, %args ) = @_;

	my $type = $args{constraint};
	if ( $type->parent and $type->parent->{uniq} == Slurpy->{uniq} ) {
		$type = $type->type_parameter || $type;
	}

	my $croaker = $self->{mite_signature}->class->_function_for_croak;

	return sprintf '%s( "Type check failed in signature for %s: %%s should be %%s", %s, %s )',
		$croaker, $self->subname, B::perlstring( $args{display_var} || $args{varname} ), B::perlstring( $type->display_name );
}

sub _make_count_fail {
	my ( $self, %args ) = @_;

	my $msg;
	my $min = $args{minimum};
	my $max = $args{minimum};
	
	if ( defined $min and defined $max and $min==$max ) {
		$msg = sprintf 'expected exactly %d parameters', $min;
	}
	elsif ( defined $max ) {
		$msg = sprintf 'expected between %d and %d parameters', $min || 0, $max;
	}
	elsif ( defined $min ) {
		$msg = sprintf 'expected at least %d parameters', $min;
	}
	else {
		$msg = 'that does not seem right';
	}

	my $croaker = $self->{mite_signature}->class->_function_for_croak;

	if ( $args{got} ) {
		return sprintf '%s( "Wrong number of parameters in signature for %%s: got %%d, %%s", %s, %s, %s )',
			$croaker, B::perlstring( $self->subname ), $args{got}, B::perlstring( $msg );
	}
	else {
		return sprintf '%s( "Wrong number of parameters in signature for %%s: got ???, %%s", %s, %s )',
			$croaker, B::perlstring( $self->subname ), B::perlstring( $msg );
	}
	
}

1;
