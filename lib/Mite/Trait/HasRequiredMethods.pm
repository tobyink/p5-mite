use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasRequiredMethods;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.009003';

has required_methods =>
  is            => ro,
  isa           => ArrayRef[MethodName],
  builder       => sub { [] };

sub add_required_methods {
    my $self = shift;

    push @{ $self->required_methods }, @_;

    return;
}

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
