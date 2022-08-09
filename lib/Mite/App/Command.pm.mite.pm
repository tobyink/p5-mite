{

    package Mite::App::Command;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.009003";

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

    # Standard Moose/Moo-style constructor
    sub new {
        my $class = ref( $_[0] ) ? ref(shift) : shift;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $self  = bless {}, $class;
        my $args =
            $meta->{HAS_BUILDARGS}
          ? $class->BUILDARGS(@_)
          : { ( @_ == 1 ) ? %{ $_[0] } : @_ };
        my $no_build = delete $args->{__no_BUILD__};

        # Attribute app (type: Object)
        # has declaration, file lib/Mite/App/Command.pm, line 11
        croak "Missing key in constructor: app" unless exists $args->{"app"};
        blessed( $args->{"app"} )
          or croak "Type check failed in constructor: %s should be %s", "app",
          "Object";
        $self->{"app"} = $args->{"app"};
        require Scalar::Util && Scalar::Util::weaken( $self->{"app"} )
          if ref $self->{"app"};

        # Attribute kingpin_command (type: Object)
        # has declaration, file lib/Mite/App/Command.pm, line 19
        if ( exists $args->{"kingpin_command"} ) {
            blessed( $args->{"kingpin_command"} )
              or croak "Type check failed in constructor: %s should be %s",
              "kingpin_command", "Object";
            $self->{"kingpin_command"} = $args->{"kingpin_command"};
        }

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(/\A(?:app|kingpin_command)\z/), keys %{$args};
        @unknown
          and croak(
            "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

        return $self;
    }

    # Used by constructor to call BUILD methods
    sub BUILDALL {
        my $class = ref( $_[0] );
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        $_->(@_) for @{ $meta->{BUILD} || [] };
    }

    # Destructor should call DEMOLISH methods
    sub DESTROY {
        my $self  = shift;
        my $class = ref($self) || $self;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $in_global_destruction =
          defined ${^GLOBAL_PHASE}
          ? ${^GLOBAL_PHASE} eq 'DESTRUCT'
          : Devel::GlobalDestruction::in_global_destruction();
        for my $demolisher ( @{ $meta->{DEMOLISH} || [] } ) {
            my $e = do {
                local ( $?, $@ );
                eval { $demolisher->( $self, $in_global_destruction ) };
                $@;
            };
            no warnings 'misc';    # avoid (in cleanup) warnings
            die $e if $e;          # rethrow
        }
        return;
    }

    my $__XS = !$ENV{MITE_PURE_PERL}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for app
    # has declaration, file lib/Mite/App/Command.pm, line 11
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "app" => "app" },
        );
    }
    else {
        *app = sub {
            @_ == 1 or croak('Reader "app" usage: $self->app()');
            $_[0]{"app"};
        };
    }

    sub _assert_blessed_app {
        my $object = do { $_[0]{"app"} };
        blessed($object) or croak("app is not a blessed object");
        $object;
    }

    # Delegated methods for app
    # has declaration, file lib/Mite/App/Command.pm, line 11
    sub config  { shift->_assert_blessed_app->config(@_) }
    sub kingpin { shift->_assert_blessed_app->kingpin(@_) }
    sub project { shift->_assert_blessed_app->project(@_) }

    # Accessors for kingpin_command
    # has declaration, file lib/Mite/App/Command.pm, line 19
    sub kingpin_command {
        @_ == 1
          or croak('Reader "kingpin_command" usage: $self->kingpin_command()');
        (
            exists( $_[0]{"kingpin_command"} ) ? $_[0]{"kingpin_command"} : (
                $_[0]{"kingpin_command"} = do {
                    my $default_value = $_[0]->_build_kingpin_command;
                    blessed($default_value)
                      or croak( "Type check failed in default: %s should be %s",
                        "kingpin_command", "Object" );
                    $default_value;
                }
            )
        );
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

    1;
}
