{

    package Mite::Role;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.006013";

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

    sub new {
        my $class = ref( $_[0] ) ? ref(shift) : shift;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $self  = bless {}, $class;
        my $args =
            $meta->{HAS_BUILDARGS}
          ? $class->BUILDARGS(@_)
          : { ( @_ == 1 ) ? %{ $_[0] } : @_ };
        my $no_build = delete $args->{__no_BUILD__};

        # Attribute: attributes
        do {
            my $value =
              exists( $args->{"attributes"} )
              ? $args->{"attributes"}
              : $Mite::Role::__attributes_DEFAULT__->($self);
            do {

                package Mite::Shim;
                ( ref($value) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $i ( values %{$value} ) {
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
              or croak "Type check failed in constructor: %s should be %s",
              "attributes", "HashRef[Mite::Attribute]";
            $self->{"attributes"} = $value;
        };

        # Attribute: name
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

        # Attribute: shim_name
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

        # Attribute: source
        if ( exists $args->{"source"} ) {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"source"} )
                      and $args->{"source"}->isa(q[Mite::Source]);
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "source", "Mite::Source";
            $self->{"source"} = $args->{"source"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"source"} )
          if exists $self->{"source"};

        # Attribute: roles
        do {
            my $value =
              exists( $args->{"roles"} )
              ? $args->{"roles"}
              : $self->_build_roles;
            do {

                package Mite::Shim;
                ( ref($value) eq 'ARRAY' ) and do {
                    my $ok = 1;
                    for my $i ( @{$value} ) {
                        ( $ok = 0, last )
                          unless (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($i)
                                  and $i->isa(q[Mite::Role]);
                            }
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "roles", "ArrayRef[Mite::Role]";
            $self->{"roles"} = $value;
        };

        # Attribute: imported_functions
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

        # Attribute: required_methods
        do {
            my $value =
              exists( $args->{"required_methods"} )
              ? $args->{"required_methods"}
              : $self->_build_required_methods;
            do {

                package Mite::Shim;
                ( ref($value) eq 'ARRAY' ) and do {
                    my $ok = 1;
                    for my $i ( @{$value} ) {
                        ( $ok = 0, last )
                          unless (
                            (
                                do {

                                    package Mite::Shim;
                                    defined($i) and do {
                                        ref( \$i ) eq 'SCALAR'
                                          or ref( \( my $val = $i ) ) eq
                                          'SCALAR';
                                    }
                                }
                            )
                            && ( do { local $_ = $i; /\A[^\W0-9]\w*\z/ } )
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "required_methods", "ArrayRef[MethodName]";
            $self->{"required_methods"} = $value;
        };

        # Enforce strict constructor
        my @unknown = grep not(
/\A(?:attributes|imported_functions|name|r(?:equired_methods|oles)|s(?:him_name|ource))\z/
        ), keys %{$args};
        @unknown
          and croak(
            "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        return $self;
    }

    sub BUILDALL {
        my $class = ref( $_[0] );
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        $_->(@_) for @{ $meta->{BUILD} || [] };
    }

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

    sub DOES {
        my ( $self, $role ) = @_;
        our %DOES;
        return $DOES{$role} if exists $DOES{$role};
        return 1            if $role eq __PACKAGE__;
        return $self->SUPER::DOES($role);
    }

    sub does {
        shift->DOES(@_);
    }

    my $__XS = !$ENV{MITE_PURE_PERL}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for attributes
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "attributes" => "attributes" },
        );
    }
    else {
        *attributes = sub {
            @_ > 1
              ? croak("attributes is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"attributes"};
        };
    }

    # Accessors for imported_functions
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "imported_functions" => "imported_functions" },
        );
    }
    else {
        *imported_functions = sub {
            @_ > 1
              ? croak(
                "imported_functions is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"imported_functions"};
        };
    }

    # Accessors for name
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "name" => "name" },
        );
    }
    else {
        *name = sub {
            @_ > 1
              ? croak("name is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"name"};
        };
    }

    # Accessors for required_methods
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "required_methods" => "required_methods" },
        );
    }
    else {
        *required_methods = sub {
            @_ > 1
              ? croak(
                "required_methods is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"required_methods"};
        };
    }

    # Accessors for roles
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "roles" => "roles" },
        );
    }
    else {
        *roles = sub {
            @_ > 1
              ? croak("roles is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"roles"};
        };
    }

    # Accessors for shim_name
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
    sub source {
        @_ > 1
          ? do {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[1] )
                      and $_[1]->isa(q[Mite::Source]);
                }
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Source" );
            $_[0]{"source"} = $_[1];
            require Scalar::Util && Scalar::Util::weaken( $_[0]{"source"} );
            $_[0];
          }
          : ( $_[0]{"source"} );
    }

    1;
}
