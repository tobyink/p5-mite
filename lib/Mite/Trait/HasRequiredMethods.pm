use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasRequiredMethods;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010001';

has required_methods =>
  is            => ro,
  isa           => ArrayRef[MethodName],
  builder       => sub { [] };

sub add_required_methods {
    my $self = shift;

    push @{ $self->required_methods }, @_;

    return;
}

before inject_mite_functions => sub {
    my ( $self, $file, $arg ) = ( shift, @_ );

    my $requested = sub { $arg->{$_[0]} ? 1 : $arg->{'!'.$_[0]} ? 0 : $arg->{'-all'} ? 1 : $_[1]; };
    my $shim      = $self->shim_name;
    my $package   = $self->name;

    no strict 'refs';

    if ( $requested->( 'requires', 1 ) ) {

        *{ $package .'::requires' } = sub {
            $self->add_required_methods( @_ );
            return;
        };

        $self->imported_keywords->{requires} = 'sub {}';
    }
};

around _compile_mop_required_methods => sub {
    my ( $next, $self ) = ( shift, shift );

    my $code = $self->$next( @_ );
    $code .= "\n" if $code;

    if ( my @req = @{ $self->required_methods } ) {
        $code .= sprintf "    \$PACKAGE->add_required_methods( %s );\n", 
            join( q{, }, map B::perlstring( $_ ), @req ),
    }

    return $code;
};

1;
