{
package MooseInteg::SomeRole;
use strict;
use warnings;

our $USES_MITE = "Mite::Role";
our $MITE_SHIM = "MooseInteg::Mite";
our $MITE_VERSION = "0.007006";
# Gather metadata for constructor and destructor
sub __META__ {
    no strict 'refs';
    no warnings 'once';
    my $class      = shift; $class = ref($class) || $class;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
        HAS_FOREIGNBUILDARGS => $class->can('FOREIGNBUILDARGS'),
    };
}

# Moose-compatibility method
sub meta {
    require MooseInteg::MOP;
    Moose::Util::find_meta( $_[0] );
}

# See UNIVERSAL
sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    return $self->SUPER::DOES( $role );
}

# Alias for Moose/Moo-compatibility
sub does {
    shift->DOES( @_ );
}

# Callback which classes consuming this role will call
sub __FINALIZE_APPLICATION__ {
    my ( $me, $target, $args ) = @_;
    our ( %CONSUMERS, @METHOD_MODIFIERS );

    # Ensure a given target only consumes this role once.
    if ( exists $CONSUMERS{$target} ) {
        return;
    }
    $CONSUMERS{$target} = 1;

    my $type = do { no strict 'refs'; ${"$target\::USES_MITE"} };
    return if $type ne 'Mite::Class';

    my @missing_methods;
    @missing_methods = grep( !$target->can($_), "number" )
        and MooseInteg::Mite::croak( "$me requires $target to implement methods: " . join q[, ], @missing_methods );

    my @roles = (  );
    my %nextargs = %{ $args || {} };
    ( $nextargs{-indirect} ||= 0 )++;
    MooseInteg::Mite::croak( "PANIC!" ) if $nextargs{-indirect} > 100;
    for my $role ( @roles ) {
        $role->__FINALIZE_APPLICATION__( $target, { %nextargs } );
    }

    my $shim = "MooseInteg::Mite";
    for my $modifier_rule ( @METHOD_MODIFIERS ) {
        my ( $modification, $names, $coderef ) = @$modifier_rule;
        $shim->$modification( $target, $names, $coderef );
    }

    return;
}

1;
}