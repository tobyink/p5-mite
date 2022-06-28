{
package Mite::App::Command::compile;
use strict;
use warnings;

BEGIN {
    require Mite::App::Command;

    use mro 'c3';
    our @ISA;
    push @ISA, q[Mite::App::Command];
}

sub new {
    my $class = shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    

    # Enforce strict constructor
    my @unknown = grep not( do { package Mite::Miteception; defined($_) and do { ref(\$_) eq 'SCALAR' or ref(\(my $val = $_)) eq 'SCALAR' } } ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

    # Call BUILD methods
    !$no_build and @{$meta->{BUILD}||[]} and $self->BUILDALL($args);

    return $self;
}

sub BUILDALL {
    $_->(@_) for @{ $Mite::META{ref($_[0])}{BUILD} || [] };
}

sub __META__ {
    no strict 'refs';
    require mro;
    my $class = shift;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } reverse @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
    };
}


1;
}