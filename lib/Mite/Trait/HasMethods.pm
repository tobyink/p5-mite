use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasMethods;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.009003';

requires qw( _function_for_croak );

BEGIN {
    *_CONSTANTS_DEFLATE = "$]" >= 5.012 && "$]" < 5.020 ? \&true : \&false;
};

has method_signatures =>
  is            => ro,
  isa           => Map[ MethodName, MiteSignature ],
  builder       => sub { {} };

sub add_method_signature {
    my ( $self, $method_name, %opts ) = @_;

    defined $self->method_signatures->{ $method_name }
        and croak( 'Method signature for %s already exists', $method_name );

    require Mite::Signature;
    $self->method_signatures->{ $method_name } = 'Mite::Signature'->new(
        method_name => $method_name,
        class => $self,
        %opts,
    );

    return;
}

sub _all_subs {
    my $self = shift;
    my $package = $self->name;
    no strict 'refs';
    my $stash = \%{"$package\::"};
    return {
        map {;
          # this is an ugly hack to populate the scalar slot of any globs, to
          # prevent perl from converting constants back into scalar refs in the
          # stash when they are used (perl 5.12 - 5.18). scalar slots on their own
          # aren't detectable through pure perl, so this seems like an acceptable
          # compromise.
          ${"${package}::${_}"} = ${"${package}::${_}"}
            if _CONSTANTS_DEFLATE;
          $_ => \&{"${package}::${_}"}
        }
        grep exists &{"${package}::${_}"},
        grep !/::\z/,
        keys %$stash
    };
}

sub native_methods {
    my $self = shift;
    my %methods = %{ $self->_all_subs };

    require B;
    for my $name ( sort keys %methods ) {
        my $cv        = B::svref_2object( $methods{$name} );
        my $stashname = eval { $cv->GV->STASH->NAME };
        $stashname eq $self->name
            or $stashname eq 'constant'
            or delete $methods{$name};
    }

    delete $methods{meta};

    return \%methods;
}

around compilation_stages => sub {
    my ( $next, $self ) = ( shift, shift );
    my @stages = $self->$next( @_ );
    push @stages, '_compile_method_signatures';
    return @stages;
};

sub _compile_method_signatures {
    my $self = shift;
    my %sigs = %{ $self->method_signatures } or return;

    my $code = "# Method signatures\n"
        . "our \%SIGNATURE_FOR;\n\n";

    for my $name ( sort keys %sigs ) {
        my $guard = $sigs{$name}->locally_set_compiling_class( $self );

        $code .= sprintf(
            '$SIGNATURE_FOR{%s} = %s;' . "\n\n",
            B::perlstring( $name ),
            $sigs{$name}->_compile_coderef,
        );

        if ( my $support = $sigs{$name}->_compile_support ) {
            $code .= "$support\n\n";
        }
    }

    return $code;
}

1;
