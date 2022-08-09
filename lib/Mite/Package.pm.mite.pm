{

    package Mite::Package;
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

        # Attribute name (type: ValidClassName)
        # has declaration, file lib/Mite/Package.pm, line 11
        croak "Missing key in constructor: name" unless exists $args->{"name"};
        (
            (
                do {

                    package Mite::Shim;
                    defined( $args->{"name"} ) and do {
                        ref( \$args->{"name"} ) eq 'SCALAR'
                          or ref( \( my $val = $args->{"name"} ) ) eq 'SCALAR';
                    }
                }
            )
              && (
                do {
                    local $_ = $args->{"name"};
                    /\A[^\W0-9]\w*(?:::[^\W0-9]\w*)*\z/;
                }
              )
          )
          or croak "Type check failed in constructor: %s should be %s", "name",
          "ValidClassName";
        $self->{"name"} = $args->{"name"};

        # Attribute shim_name (type: ValidClassName)
        # has declaration, file lib/Mite/Package.pm, line 23
        if ( exists $args->{"shim_name"} ) {
            (
                (
                    do {

                        package Mite::Shim;
                        defined( $args->{"shim_name"} ) and do {
                            ref( \$args->{"shim_name"} ) eq 'SCALAR'
                              or ref( \( my $val = $args->{"shim_name"} ) ) eq
                              'SCALAR';
                        }
                    }
                )
                  && (
                    do {
                        local $_ = $args->{"shim_name"};
                        /\A[^\W0-9]\w*(?:::[^\W0-9]\w*)*\z/;
                    }
                  )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "shim_name", "ValidClassName";
            $self->{"shim_name"} = $args->{"shim_name"};
        }

        # Attribute source (type: Mite::Source)
        # has declaration, file lib/Mite/Package.pm, line 25
        if ( exists $args->{"source"} ) {
            blessed( $args->{"source"} )
              && $args->{"source"}->isa("Mite::Source")
              or croak "Type check failed in constructor: %s should be %s",
              "source", "Mite::Source";
            $self->{"source"} = $args->{"source"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"source"} )
          if ref $self->{"source"};

        # Attribute imported_functions (type: Map[MethodName,Str])
        # has declaration, file lib/Mite/Package.pm, line 34
        do {
            my $value =
              exists( $args->{"imported_functions"} )
              ? $args->{"imported_functions"}
              : $self->_build_imported_functions;
            do {

                package Mite::Shim;
                ( ref($value) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $v ( values %{$value} ) {
                        ( $ok = 0, last ) unless do {

                            package Mite::Shim;
                            defined($v) and do {
                                ref( \$v ) eq 'SCALAR'
                                  or ref( \( my $val = $v ) ) eq 'SCALAR';
                            }
                        }
                    };
                    for my $k ( keys %{$value} ) {
                        ( $ok = 0, last )
                          unless (
                            (
                                do {

                                    package Mite::Shim;
                                    defined($k) and do {
                                        ref( \$k ) eq 'SCALAR'
                                          or ref( \( my $val = $k ) ) eq
                                          'SCALAR';
                                    }
                                }
                            )
                            && ( do { local $_ = $k; /\A[^\W0-9]\w*\z/ } )
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "imported_functions", "Map[MethodName,Str]";
            $self->{"imported_functions"} = $value;
        };

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown =
          grep not(/\A(?:imported_functions|name|s(?:him_name|ource))\z/),
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

    my $__XS = !$ENV{MITE_PURE_PERL}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for imported_functions
    # has declaration, file lib/Mite/Package.pm, line 34
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "imported_functions" => "imported_functions" },
        );
    }
    else {
        *imported_functions = sub {
            @_ == 1
              or croak(
                'Reader "imported_functions" usage: $self->imported_functions()'
              );
            $_[0]{"imported_functions"};
        };
    }

    # Accessors for name
    # has declaration, file lib/Mite/Package.pm, line 11
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "name" => "name" },
        );
    }
    else {
        *name = sub {
            @_ == 1 or croak('Reader "name" usage: $self->name()');
            $_[0]{"name"};
        };
    }

    # Accessors for shim_name
    # has declaration, file lib/Mite/Package.pm, line 23
    sub shim_name {
        @_ > 1
          ? do {
            (
                (
                    do {

                        package Mite::Shim;
                        defined( $_[1] ) and do {
                            ref( \$_[1] ) eq 'SCALAR'
                              or ref( \( my $val = $_[1] ) ) eq 'SCALAR';
                        }
                    }
                )
                  && (
                    do { local $_ = $_[1]; /\A[^\W0-9]\w*(?:::[^\W0-9]\w*)*\z/ }
                  )
              )
              or croak(
                "Type check failed in %s: value should be %s",
                "accessor",
                "ValidClassName"
              );
            $_[0]{"shim_name"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"shim_name"} ) ? $_[0]{"shim_name"} : (
                    $_[0]{"shim_name"} = do {
                        my $default_value = $_[0]->_build_shim_name;
                        (
                            (
                                do {

                                    package Mite::Shim;
                                    defined($default_value) and do {
                                        ref( \$default_value ) eq 'SCALAR'
                                          or
                                          ref( \( my $val = $default_value ) )
                                          eq 'SCALAR';
                                    }
                                }
                            )
                              && (
                                do {
                                    local $_ = $default_value;
                                    /\A[^\W0-9]\w*(?:::[^\W0-9]\w*)*\z/;
                                }
                              )
                          )
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "shim_name",
                            "ValidClassName"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for source
    # has declaration, file lib/Mite/Package.pm, line 25
    sub source {
        @_ > 1
          ? do {
            blessed( $_[1] ) && $_[1]->isa("Mite::Source")
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Source" );
            $_[0]{"source"} = $_[1];
            require Scalar::Util && Scalar::Util::weaken( $_[0]{"source"} )
              if ref $_[0]{"source"};
            $_[0];
          }
          : ( $_[0]{"source"} );
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
