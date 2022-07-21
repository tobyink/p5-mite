{

    package Mite::Class;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.007004";

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

    BEGIN {
        require Mite::Role;

        use mro 'c3';
        our @ISA;
        push @ISA, "Mite::Role";
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

        # Attribute attributes (type: HashRef[Mite::Attribute])
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

        # Attribute name (type: ValidClassName)
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
          if ref $self->{"source"};

        # Attribute roles (type: ArrayRef[Mite::Role])
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

        # Attribute imported_functions (type: Map[MethodName,Str])
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

        # Attribute required_methods (type: ArrayRef[MethodName])
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

        # Attribute method_signatures (type: Map[MethodName,Mite::Signature])
        do {
            my $value =
              exists( $args->{"method_signatures"} )
              ? $args->{"method_signatures"}
              : $self->_build_method_signatures;
            do {

                package Mite::Shim;
                ( ref($value) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $v ( values %{$value} ) {
                        ( $ok = 0, last )
                          unless (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($v)
                                  and $v->isa(q[Mite::Signature]);
                            }
                          );
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
              "method_signatures", "Map[MethodName,Mite::Signature]";
            $self->{"method_signatures"} = $value;
        };

        # Attribute extends (type: ArrayRef[ValidClassName])
        do {
            my $value =
              exists( $args->{"extends"} )
              ? $args->{"extends"}
              : $Mite::Class::__extends_DEFAULT__->($self);
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
                            && (
                                do {
                                    local $_ = $i;
                                    /\A[^\W0-9]\w*(?:::[^\W0-9]\w*)*\z/;
                                }
                            )
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "extends", "ArrayRef[ValidClassName]";
            $self->{"extends"} = $value;
            $self->_trigger_extends( $self->{"extends"} )
              if exists $args->{"extends"};
        };

        # Attribute parents (type: ArrayRef[Mite::Class])
        if ( exists $args->{"parents"} ) {
            (
                do { package Mite::Shim; ref( $args->{"parents"} ) eq 'ARRAY' }
                  and do {
                    my $ok = 1;
                    for my $i ( @{ $args->{"parents"} } ) {
                        ( $ok = 0, last )
                          unless (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($i)
                                  and $i->isa(q[Mite::Class]);
                            }
                          );
                    };
                    $ok;
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "parents", "ArrayRef[Mite::Class]";
            $self->{"parents"} = $args->{"parents"};
        }

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(
/\A(?:attributes|extends|imported_functions|method_signatures|name|parents|r(?:equired_methods|oles)|s(?:him_name|ource))\z/
        ), keys %{$args};
        @unknown
          and croak(
            "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

        return $self;
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

    # Accessors for extends
    sub superclasses {
        @_ > 1
          ? do {
            my @oldvalue;
            @oldvalue = $_[0]{"extends"} if exists $_[0]{"extends"};
            do {

                package Mite::Shim;
                ( ref( $_[1] ) eq 'ARRAY' ) and do {
                    my $ok = 1;
                    for my $i ( @{ $_[1] } ) {
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
                            && (
                                do {
                                    local $_ = $i;
                                    /\A[^\W0-9]\w*(?:::[^\W0-9]\w*)*\z/;
                                }
                            )
                          );
                    };
                    $ok;
                }
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "ArrayRef[ValidClassName]" );
            $_[0]{"extends"} = $_[1];
            $_[0]->_trigger_extends( $_[0]{"extends"}, @oldvalue );
            $_[0];
          }
          : ( $_[0]{"extends"} );
    }

    # Accessors for parents
    sub _clear_parents { delete $_[0]{"parents"}; $_[0]; }

    sub parents {
        @_ > 1
          ? croak("parents is a read-only attribute of @{[ref $_[0]]}")
          : (
            exists( $_[0]{"parents"} ) ? $_[0]{"parents"} : (
                $_[0]{"parents"} = do {
                    my $default_value = $_[0]->_build_parents;
                    do {

                        package Mite::Shim;
                        ( ref($default_value) eq 'ARRAY' ) and do {
                            my $ok = 1;
                            for my $i ( @{$default_value} ) {
                                ( $ok = 0, last )
                                  unless (
                                    do {
                                        use Scalar::Util ();
                                        Scalar::Util::blessed($i)
                                          and $i->isa(q[Mite::Class]);
                                    }
                                  );
                            };
                            $ok;
                        }
                      }
                      or croak( "Type check failed in default: %s should be %s",
                        "parents", "ArrayRef[Mite::Class]" );
                    $default_value;
                }
            )
          );
    }

    1;
}
