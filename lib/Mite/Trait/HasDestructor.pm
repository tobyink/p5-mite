use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasDestructor;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.013000';

requires qw(
    linear_isa
    _get_parent
    _compile_meta
);

around compilation_stages => sub {
    my ( $next, $self ) = ( shift, shift );

    # Check if we are inheriting from a Mite class in this project
    my $inherit_from_mite = do {
        # First parent
        my $first_isa = do {
            my @isa = $self->linear_isa;
            shift @isa;
            shift @isa;
        };
        !! ( $first_isa and $self->_get_parent( $first_isa ) );
    };

    my @stages = $self->$next( @_ );

    # Only need these stages if not already inheriting from Mite
    push @stages, qw(
        _compile_destroy
    ) unless $inherit_from_mite;

    return @stages;
};

sub _compile_destroy {
    my $self = shift;
    sprintf <<'CODE', $self->_compile_meta( '$class', '$self' );
# Destructor should call DEMOLISH methods
sub DESTROY {
    my $self  = shift;
    my $class = ref( $self ) || $self;
    my $meta  = %s;
    my $in_global_destruction = defined ${^GLOBAL_PHASE}
        ? ${^GLOBAL_PHASE} eq 'DESTRUCT'
        : Devel::GlobalDestruction::in_global_destruction();
    for my $demolisher ( @{ $meta->{DEMOLISH} || [] } ) {
        my $e = do {
            local ( $?, $@ );
            eval { $demolisher->( $self, $in_global_destruction ) };
            $@;
        };
        no warnings 'misc'; # avoid (in cleanup) warnings
        die $e if $e;       # rethrow
    }
    return;
}
CODE
}

1;
