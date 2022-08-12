{

    package Mite::Trait::HasRoles;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Role";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.010001";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) =
          ( "Mite::Shim", "Mite::Trait::HasRoles" );
        (
            *after,    *around,        *before,
            *field,    *has,           *param,
            *requires, *signature_for, *with
          )
          = do {

            package Mite::Shim;
            no warnings 'redefine';
            (
                sub { $SHIM->HANDLE_after( $CALLER, "role", @_ ) },
                sub { $SHIM->HANDLE_around( $CALLER, "role", @_ ) },
                sub { $SHIM->HANDLE_before( $CALLER, "role", @_ ) },
                sub { $SHIM->HANDLE_has( $CALLER, field => @_ ) },
                sub { $SHIM->HANDLE_has( $CALLER, has   => @_ ) },
                sub { $SHIM->HANDLE_has( $CALLER, param => @_ ) },
                sub { },
                sub { $SHIM->HANDLE_signature_for( $CALLER, "role", @_ ) },
                sub { $SHIM->HANDLE_with( $CALLER, @_ ) },
            );
          };
    }

    # Mite imports
    BEGIN {
        require Scalar::Util;
        *STRICT  = \&Mite::Shim::STRICT;
        *bare    = \&Mite::Shim::bare;
        *blessed = \&Scalar::Util::blessed;
        *carp    = \&Mite::Shim::carp;
        *confess = \&Mite::Shim::confess;
        *croak   = \&Mite::Shim::croak;
        *false   = \&Mite::Shim::false;
        *guard   = \&Mite::Shim::guard;
        *lazy    = \&Mite::Shim::lazy;
        *ro      = \&Mite::Shim::ro;
        *rw      = \&Mite::Shim::rw;
        *rwp     = \&Mite::Shim::rwp;
        *true    = \&Mite::Shim::true;
    }

    # Gather metadata for constructor and destructor
    sub __META__ {
        no strict 'refs';
        no warnings 'once';
        my $class = shift;
        $class = ref($class) || $class;
        my $linear_isa = mro::get_linear_isa($class);
        return {
            BUILD => [
                map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
                map { "$_\::BUILD" } reverse @$linear_isa
            ],
            DEMOLISH => [
                map   { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
                  map { "$_\::DEMOLISH" } @$linear_isa
            ],
            HAS_BUILDARGS        => $class->can('BUILDARGS'),
            HAS_FOREIGNBUILDARGS => $class->can('FOREIGNBUILDARGS'),
        };
    }

    # See UNIVERSAL
    sub DOES {
        my ( $self, $role ) = @_;
        our %DOES;
        return $DOES{$role} if exists $DOES{$role};
        return 1            if $role eq __PACKAGE__;
        return $self->SUPER::DOES($role);
    }

    # Alias for Moose/Moo-compatibility
    sub does {
        shift->DOES(@_);
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
        @missing_methods = grep( !$target->can($_),
            "compilation_stages", "inject_mite_functions",
            "native_methods",     "source" )
          and croak( "$me requires $target to implement methods: " . join q[, ],
            @missing_methods );

        my @roles    = ();
        my %nextargs = %{ $args || {} };
        ( $nextargs{-indirect} ||= 0 )++;
        croak("PANIC!") if $nextargs{-indirect} > 100;
        for my $role (@roles) {
            $role->__FINALIZE_APPLICATION__( $target, {%nextargs} );
        }

        my $shim = "Mite::Shim";
        for my $modifier_rule (@METHOD_MODIFIERS) {
            my ( $modification, $names, $coderef ) = @$modifier_rule;
            $shim->$modification( $target, $names, $coderef );
        }

        return;
    }

    1;
}
