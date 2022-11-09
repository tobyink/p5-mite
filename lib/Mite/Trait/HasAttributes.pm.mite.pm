{

    package Mite::Trait::HasAttributes;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Role";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.010008";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) =
          ( "Mite::Shim", "Mite::Trait::HasAttributes" );
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
        if ( $INC{'Moose/Util.pm'}
            and my $meta = Moose::Util::find_meta( ref $self or $self ) )
        {
            $meta->can('does_role') and $meta->does_role($role) and return 1;
        }
        return $self->SUPER::DOES($role);
    }

    # Alias for Moose/Moo-compatibility
    sub does {
        shift->DOES(@_);
    }

    # Method signatures
    our %SIGNATURE_FOR;

    $SIGNATURE_FOR{"add_attributes"} = sub {
        my $__NEXT__ = shift;

        my ( @out, %tmp, $tmp, $dtmp, @head );

        @_ >= 1
          or
          croak( "Wrong number of parameters in signature for %s: got %d, %s",
            "add_attributes", scalar(@_), "expected exactly 1 parameters" );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
        ( defined( $head[0] ) )
          or croak(
"Type check failed in signature for add_attributes: %s should be %s",
            "\$_[0]", "Defined"
          );

        my $SLURPY = [ @_[ 0 .. $#_ ] ];

        # Parameter $SLURPY (type: Slurpy[ArrayRef[Mite::Attribute]])
        (
            do {

                package Mite::Shim;
                ( ref($SLURPY) eq 'ARRAY' ) and do {
                    my $ok = 1;
                    for my $i ( @{$SLURPY} ) {
                        ( $ok = 0, last )
                          unless (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($i)
                                  and $i->isa(q[Mite::Attribute]);
                            }
                          );
                    };
                    $ok;
                }
            }
          )
          or croak(
"Type check failed in signature for add_attributes: %s should be %s",
            "\$SLURPY", "ArrayRef[Mite::Attribute]"
          );
        push( @out, $SLURPY );

        do { @_ = ( @head, @out ); goto $__NEXT__ };
    };

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
            "_compile_mop_attributes", "_compile_pragmas",
            "_function_for_croak",     "compilation_stages",
            "inject_mite_functions" )
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
            my $handler = "HANDLE_$modification";
            $shim->$handler( $target, "class", $names, $coderef );
        }

        return;
    }

    1;
}
