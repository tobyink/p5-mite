use 5.010001;
use strict;
use warnings;

package Mite::Attribute::SHV::CodeGen;

# SHV uses Mite, so cannot be required by Mite during bootstrapping
require Mite::Shim;
if ( not Mite::Shim::_is_compiling() ) {
	require Sub::HandlesVia::CodeGenerator;
	our @ISA = 'Sub::HandlesVia::CodeGenerator';
}

sub _handle_sigcheck {
	my ( $self, $method_name, $handler, $env, $code, $state ) = @_;

	# If there's a proper signature for the method...
	#
	if ( @{ $handler->signature || [] } ) {
		
		# Generate code using Type::Params to check the signature.
		# We also need to close over the signature.
		#
		require Mite::Signature::Compiler;
		
		my $compiler = 'Mite::Signature::Compiler'->new_from_compile(
			positional => {
				package        => $self->target,
				subname        => $method_name,
				is_wrapper     => !!0,
				mite_signature => $self->{mite_attribute}, # HasMethods['class']
			},
			$state->{shifted_self}
				? @{ $handler->signature }
				: ( Types::Standard::Object(), @{ $handler->signature } ),
		);
		
		my $sigcode = $compiler->coderef->code;
		$sigcode =~ s/^\s+|\s+$//gs;
		if ( $sigcode =~ /return/ ) {
			push @$code, sprintf '$__signature ||= %s;', $sigcode;
			push @$code, '@_ = &$__signature;';
			$env->{'$__signature'} = \0;
		}
		else {
			$sigcode =~ s/^sub/do/;
			push @$code, sprintf '@_ = %s;', $sigcode;
		}
		
		# As we've now inserted a signature check, we can stop worrying
		# about signature checks.
		#
		$state->{signature_check_needed} = 0;
	}
	# There is no proper signature, but there's still check the
	# arity of the method.
	#
	else {
		# What is the arity?
		#
		my $min_args = $handler->min_args || 0;
		my $max_args = $handler->max_args;
		
		my $plus = 1;
		if ( $state->{shifted_self} ) {
			$plus = 0;
		}
		
		# What usage message do we want to print if wrong arity?
		#
		my $usg = sprintf(
			'%s("Wrong number of parameters in signature for %s; usage: ".%s)',
			$self->{mite_attribute}->_function_for_croak,
			$method_name,
			B::perlstring( $self->generate_usage_string( $method_name, $handler->usage ) ),
		);
		
		# Insert the check into the code.
		#
		if (defined $min_args and defined $max_args and $min_args==$max_args) {
			push @$code, sprintf('@_==%d or %s;', $min_args + $plus, $usg);
		}
		elsif (defined $min_args and defined $max_args) {
			push @$code, sprintf('(@_ >= %d and @_ <= %d) or %s;', $min_args + $plus, $max_args + $plus, $usg);
		}
		elsif (defined $min_args and $min_args > 0) {
			push @$code, sprintf('@_ >= %d or %s;', $min_args + $plus, $usg);
		}
		
		# We are still lacking a proper signature check though, so note
		# that in the state. The information can be used by
		# additional_validation coderefs.
		#
		$state->{signature_check_needed} = !!1;
	}
	
	return $self;
}

1;
