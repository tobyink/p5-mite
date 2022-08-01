{

    package Mite::App;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.008000";

    BEGIN {
        require Scalar::Util;
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

        # Attribute commands (type: HashRef[Object])
        # has declaration, file lib/Mite/App.pm, line 22
        do {
            my $value =
              exists( $args->{"commands"} ) ? $args->{"commands"} : {};
            do {

                package Mite::Shim;
                ( ref($value) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $i ( values %{$value} ) {
                        ( $ok = 0, last )
                          unless (
                            do {

                                package Mite::Shim;
                                use Scalar::Util ();
                                Scalar::Util::blessed($i);
                            }
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "commands", "HashRef[Object]";
            $self->{"commands"} = $value;
        };

        # Attribute kingpin (type: Object)
        # has declaration, file lib/Mite/App.pm, line 28
        if ( exists $args->{"kingpin"} ) {
            blessed( $args->{"kingpin"} )
              or croak "Type check failed in constructor: %s should be %s",
              "kingpin", "Object";
            $self->{"kingpin"} = $args->{"kingpin"};
        }

        # Attribute project (type: Mite::Project)
        # has declaration, file lib/Mite/App.pm, line 36
        if ( exists $args->{"project"} ) {
            blessed( $args->{"project"} )
              && $args->{"project"}->isa("Mite::Project")
              or croak "Type check failed in constructor: %s should be %s",
              "project", "Mite::Project";
            $self->{"project"} = $args->{"project"};
        }

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(/\A(?:commands|kingpin|project)\z/),
          keys %{$args};
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

    my $__XS = !$ENV{MITE_PURE_PERL}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for commands
    # has declaration, file lib/Mite/App.pm, line 22
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "commands" => "commands" },
        );
    }
    else {
        *commands = sub {
            @_ > 1
              ? croak("commands is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"commands"};
        };
    }

    # Accessors for kingpin
    # has declaration, file lib/Mite/App.pm, line 28
    sub _assert_blessed_kingpin {
        my $object = do {
            (
                exists( $_[0]{"kingpin"} ) ? $_[0]{"kingpin"} : (
                    $_[0]{"kingpin"} = do {
                        my $default_value = $_[0]->_build_kingpin;
                        blessed($default_value)
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "kingpin", "Object" );
                        $default_value;
                    }
                )
            )
        };
        blessed($object) or croak("kingpin is not a blessed object");
        $object;
    }

    sub kingpin {
        @_ > 1
          ? croak("kingpin is a read-only attribute of @{[ref $_[0]]}")
          : (
            exists( $_[0]{"kingpin"} ) ? $_[0]{"kingpin"} : (
                $_[0]{"kingpin"} = do {
                    my $default_value = $_[0]->_build_kingpin;
                    blessed($default_value)
                      or croak( "Type check failed in default: %s should be %s",
                        "kingpin", "Object" );
                    $default_value;
                }
            )
          );
    }

    # Delegated methods for kingpin
    # has declaration, file lib/Mite/App.pm, line 28
    sub _parse_argv { shift->_assert_blessed_kingpin->parse(@_) }

    # Accessors for project
    # has declaration, file lib/Mite/App.pm, line 36
    sub _assert_blessed_project {
        my $object = do {
            (
                exists( $_[0]{"project"} ) ? $_[0]{"project"} : (
                    $_[0]{"project"} = do {
                        my $default_value = $_[0]->_build_project;
                        blessed($default_value)
                          && $default_value->isa("Mite::Project")
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "project", "Mite::Project" );
                        $default_value;
                    }
                )
            )
        };
        blessed($object) or croak("project is not a blessed object");
        $object;
    }

    sub project {
        @_ > 1
          ? croak("project is a read-only attribute of @{[ref $_[0]]}")
          : (
            exists( $_[0]{"project"} ) ? $_[0]{"project"} : (
                $_[0]{"project"} = do {
                    my $default_value = $_[0]->_build_project;
                    blessed($default_value)
                      && $default_value->isa("Mite::Project")
                      or croak( "Type check failed in default: %s should be %s",
                        "project", "Mite::Project" );
                    $default_value;
                }
            )
          );
    }

    # Delegated methods for project
    # has declaration, file lib/Mite/App.pm, line 36
    sub config { shift->_assert_blessed_project->config(@_) }

    1;
}
