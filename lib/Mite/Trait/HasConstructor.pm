use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasConstructor;
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

    # Need a constructor if we're not inheriting from Mite,
    # or if we define any new attributes.
    push @stages, '_compile_new'
        if !$inherit_from_mite
        || keys %{ $self->attributes };

    # Only need these stages if not already inheriting from Mite
    push @stages, qw(
        _compile_buildall_method
    ) unless $inherit_from_mite;

    return @stages;
};

sub _compile_new {
    my $self = shift;
    my @vars = ('$class', '$self', '$args', '$meta');

    return sprintf <<'CODE', $self->_compile_meta(@vars), $self->_compile_bless(@vars), $self->_compile_buildargs(@vars), $self->_compile_init_attributes(@vars), $self->_compile_buildall(@vars, '$no_build'), $self->_compile_strict_constructor(@vars);
# Standard Moose/Moo-style constructor
sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = %s;
    my $self  = %s;
    my $args  = %s;
    my $no_build = delete $args->{__no_BUILD__};

%s

    # Call BUILD methods
    %s

    # Unrecognized parameters
    %s

    return $self;
}
CODE
}

sub _compile_bless {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;

    my $simple_bless = "bless {}, $classvar";

    # Force parents to be loaded
    $self->parents;

    # First parent with &new
    my ( $first_isa ) = do {
        my @isa = $self->linear_isa;
        shift @isa;
        no strict 'refs';
        grep +(defined &{$_.'::new'}), @isa;
    };

    # If we're not inheriting from anything with a constructor: simple case
    $first_isa or return $simple_bless;

    # Inheriting from a Mite class in this project: simple case
    my $first_parent = $self->_get_parent( $first_isa )
        and return $simple_bless;

    # Inheriting from a Moose/Moo/Mite/Class::Tiny class:
    #   call buildargs
    #   set $args->{__no_BUILD__}
    #   call parent class constructor
    if ( $first_isa->can( 'BUILDALL' ) ) {
        return sprintf 'do { my %s = %s; %s->{__no_BUILD__} = 1; %s->SUPER::new( %s ) }',
            $argvar, $self->_compile_buildargs($classvar, $selfvar, $argvar, $metavar), $argvar, $classvar, $argvar;
    }

    # Inheriting from some random class
    #    call FOREIGNBUILDARGS if it exists
    #    pass return value or @_ to parent class constructor
    return sprintf '%s->SUPER::new( %s->{HAS_FOREIGNBUILDARGS} ? %s->FOREIGNBUILDARGS( @_ ) : @_ )',
        $classvar, $metavar, $classvar;
}

sub _compile_buildargs {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;
    return sprintf '%s->{HAS_BUILDARGS} ? %s->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %%{$_[0]} : @_ }',
        $metavar, $classvar;
}

sub _compile_strict_constructor {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;

    my @allowed =
        grep { defined $_ }
        map { ( $_->init_arg, $_->_all_aliases ) }
        values %{ $self->all_attributes };
    my $check = do {
        local $Type::Tiny::AvoidCallbacks = 1;
        my $enum = Enum->of( @allowed );
        $enum->can( '_regexp' )  # not part of official API
            ? sprintf( '/\\A%s\\z/', $enum->_regexp )
            : $enum->inline_check( '$_' );
    };

    my $code = sprintf 'my @unknown = grep not( %s ), keys %%{%s}; @unknown and %s( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );',
        $check, $argvar, $self->_function_for_croak;
    if ( my $autolax = $self->autolax ) {
        $code = "if ( $autolax ) { $code }";
    }
    return $code;
}

sub _compile_buildall {
    my ( $self, $classvar, $selfvar, $argvar, $metavar, $nobuildvar ) = @_;
    return sprintf '%s->BUILDALL( %s ) if ( ! %s and @{ %s->{BUILD} || [] } );',
        $selfvar, $argvar, $nobuildvar, $metavar;
}

sub _compile_buildall_method {
    my $self = shift;

    return sprintf <<'CODE', $self->_compile_meta( '$class', '$_[0]', '$_[1]', '$meta' ),
# Used by constructor to call BUILD methods
sub BUILDALL {
    my $class = ref( $_[0] );
    my $meta  = %s;
    $_->( @_ ) for @{ $meta->{BUILD} || [] };
}
CODE
}

1;
