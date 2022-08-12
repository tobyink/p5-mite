{

    package Mite::Class;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.010002";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) = ( "Mite::Shim", "Mite::Class" );
        (
            *after, *around, *before,        *extends, *field,
            *has,   *param,  *signature_for, *with
          )
          = do {

            package Mite::Shim;
            no warnings 'redefine';
            (
                sub { $SHIM->HANDLE_after( $CALLER, "class", @_ ) },
                sub { $SHIM->HANDLE_around( $CALLER, "class", @_ ) },
                sub { $SHIM->HANDLE_before( $CALLER, "class", @_ ) },
                sub { },
                sub { $SHIM->HANDLE_has( $CALLER, field => @_ ) },
                sub { $SHIM->HANDLE_has( $CALLER, has   => @_ ) },
                sub { $SHIM->HANDLE_has( $CALLER, param => @_ ) },
                sub { $SHIM->HANDLE_signature_for( $CALLER, "class", @_ ) },
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

    BEGIN {
        require Mite::Package;

        use mro 'c3';
        our @ISA;
        push @ISA, "Mite::Package";
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

        # Attribute imported_keywords (type: Map[MethodName,Str])
        # has declaration, file lib/Mite/Package.pm, line 39
        do {
            my $value =
              exists( $args->{"imported_keywords"} )
              ? $args->{"imported_keywords"}
              : $self->_build_imported_keywords;
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
              "imported_keywords", "Map[MethodName,Str]";
            $self->{"imported_keywords"} = $value;
        };

        # Attribute extends (type: ArrayRef[ValidClassName])
        # has declaration, file lib/Mite/Trait/HasSuperclasses.pm, line 28
        do {
            my $value =
              exists( $args->{"extends"} )
              ? $args->{"extends"}
              : $Mite::Trait::HasSuperclasses::__extends_DEFAULT__->(
                $self);
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
            $self->_trigger_extends( $self->{"extends"} );
        };

        # Attribute superclass_args (type: Map[NonEmptyStr,HashRef|Undef])
        # has declaration, file lib/Mite/Trait/HasSuperclasses.pm, line 33
        do {
            my $value =
              exists( $args->{"superclass_args"} )
              ? $args->{"superclass_args"}
              : $self->_build_superclass_args;
            do {

                package Mite::Shim;
                ( ref($value) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $v ( values %{$value} ) {
                        ( $ok = 0, last ) unless do {

                            package Mite::Shim;
                            ( ( ref($v) eq 'HASH' ) or ( !defined($v) ) );
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
                            && ( length($k) > 0 )
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "superclass_args", "Map[NonEmptyStr,HashRef|Undef]";
            $self->{"superclass_args"} = $value;
        };

        # Attribute parents (type: ArrayRef[Mite::Class])
        # has declaration, file lib/Mite/Trait/HasSuperclasses.pm, line 36
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

        # Attribute attributes (type: HashRef[Mite::Attribute])
        # has declaration, file lib/Mite/Trait/HasAttributes.pm, line 16
        do {
            my $value =
              exists( $args->{"attributes"} )
              ? $args->{"attributes"}
              : $Mite::Trait::HasAttributes::__attributes_DEFAULT__
              ->($self);
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

        # Attribute roles (type: ArrayRef[Mite::Role])
        # has declaration, file lib/Mite/Trait/HasRoles.pm, line 19
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

        # Attribute role_args (type: Map[NonEmptyStr,HashRef|Undef])
        # has declaration, file lib/Mite/Trait/HasRoles.pm, line 24
        do {
            my $value =
              exists( $args->{"role_args"} )
              ? $args->{"role_args"}
              : $self->_build_role_args;
            do {

                package Mite::Shim;
                ( ref($value) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $v ( values %{$value} ) {
                        ( $ok = 0, last ) unless do {

                            package Mite::Shim;
                            ( ( ref($v) eq 'HASH' ) or ( !defined($v) ) );
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
                            && ( length($k) > 0 )
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "role_args", "Map[NonEmptyStr,HashRef|Undef]";
            $self->{"role_args"} = $value;
        };

        # Attribute method_signatures (type: Map[MethodName,Mite::Signature])
        # has declaration, file lib/Mite/Trait/HasMethods.pm, line 20
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

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(
/\A(?:attributes|extends|imported_(?:functions|keywords)|method_signatures|name|parents|role(?:_args|s)|s(?:him_name|ource|uperclass_args))\z/
        ), keys %{$args};
        @unknown
          and croak(
            "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

        return $self;
    }

    my $__XS = !$ENV{MITE_PURE_PERL}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for attributes
    # has declaration, file lib/Mite/Trait/HasAttributes.pm, line 16
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "attributes" => "attributes" },
        );
    }
    else {
        *attributes = sub {
            @_ == 1 or croak('Reader "attributes" usage: $self->attributes()');
            $_[0]{"attributes"};
        };
    }

    # Accessors for extends
    # has declaration, file lib/Mite/Trait/HasSuperclasses.pm, line 28
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

    # Accessors for method_signatures
    # has declaration, file lib/Mite/Trait/HasMethods.pm, line 20
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "method_signatures" => "method_signatures" },
        );
    }
    else {
        *method_signatures = sub {
            @_ == 1
              or croak(
                'Reader "method_signatures" usage: $self->method_signatures()');
            $_[0]{"method_signatures"};
        };
    }

    # Accessors for parents
    # has declaration, file lib/Mite/Trait/HasSuperclasses.pm, line 36
    sub _clear_parents {
        @_ == 1
          or croak('Clearer "_clear_parents" usage: $self->_clear_parents()');
        delete $_[0]{"parents"};
        $_[0];
    }

    sub parents {
        @_ == 1 or croak('Reader "parents" usage: $self->parents()');
        (
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

    # Accessors for role_args
    # has declaration, file lib/Mite/Trait/HasRoles.pm, line 24
    sub role_args {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                ( ref( $_[1] ) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $v ( values %{ $_[1] } ) {
                        ( $ok = 0, last ) unless do {

                            package Mite::Shim;
                            ( ( ref($v) eq 'HASH' ) or ( !defined($v) ) );
                        }
                    };
                    for my $k ( keys %{ $_[1] } ) {
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
                            && ( length($k) > 0 )
                          );
                    };
                    $ok;
                }
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Map[NonEmptyStr,HashRef|Undef]" );
            $_[0]{"role_args"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"role_args"} );
    }

    # Accessors for roles
    # has declaration, file lib/Mite/Trait/HasRoles.pm, line 19
    sub roles {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                ( ref( $_[1] ) eq 'ARRAY' ) and do {
                    my $ok = 1;
                    for my $i ( @{ $_[1] } ) {
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
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "ArrayRef[Mite::Role]" );
            $_[0]{"roles"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"roles"} );
    }

    # Accessors for superclass_args
    # has declaration, file lib/Mite/Trait/HasSuperclasses.pm, line 33
    sub superclass_args {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                ( ref( $_[1] ) eq 'HASH' ) and do {
                    my $ok = 1;
                    for my $v ( values %{ $_[1] } ) {
                        ( $ok = 0, last ) unless do {

                            package Mite::Shim;
                            ( ( ref($v) eq 'HASH' ) or ( !defined($v) ) );
                        }
                    };
                    for my $k ( keys %{ $_[1] } ) {
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
                            && ( length($k) > 0 )
                          );
                    };
                    $ok;
                }
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Map[NonEmptyStr,HashRef|Undef]" );
            $_[0]{"superclass_args"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"superclass_args"} );
    }

    BEGIN {
        require Mite::Trait::HasSuperclasses;
        require Mite::Trait::HasConstructor;
        require Mite::Trait::HasDestructor;
        require Mite::Trait::HasAttributes;
        require Mite::Trait::HasRoles;
        require Mite::Trait::HasMethods;
        require Mite::Trait::HasMOP;

        our %DOES = (
            "Mite::Class"                  => 1,
            "Mite::Trait::HasSuperclasses" => 1,
            "Mite::Trait::HasConstructor"  => 1,
            "Mite::Trait::HasDestructor"   => 1,
            "Mite::Trait::HasAttributes"   => 1,
            "Mite::Trait::HasRoles"        => 1,
            "Mite::Trait::HasMethods"      => 1,
            "Mite::Trait::HasMOP"          => 1
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

    # Methods from roles
    sub _all_subs { goto \&Mite::Trait::HasMethods::_all_subs; }

    sub _build_method_signatures {
        goto \&Mite::Trait::HasMethods::_build_method_signatures;
    }

    sub _build_parents {
        goto \&Mite::Trait::HasSuperclasses::_build_parents;
    }

    sub _build_role_args {
        goto \&Mite::Trait::HasRoles::_build_role_args;
    }
    sub _build_roles { goto \&Mite::Trait::HasRoles::_build_roles; }

    sub _build_superclass_args {
        goto \&Mite::Trait::HasSuperclasses::_build_superclass_args;
    }

    sub _compile_attribute_accessors {
        goto
          \&Mite::Trait::HasAttributes::_compile_attribute_accessors;
    }

    sub _compile_bless {
        goto \&Mite::Trait::HasConstructor::_compile_bless;
    }

    sub _compile_buildall {
        goto \&Mite::Trait::HasConstructor::_compile_buildall;
    }

    sub _compile_buildall_method {
        goto \&Mite::Trait::HasConstructor::_compile_buildall_method;
    }

    sub _compile_buildargs {
        goto \&Mite::Trait::HasConstructor::_compile_buildargs;
    }

    sub _compile_composed_methods {
        goto \&Mite::Trait::HasRoles::_compile_composed_methods;
    }

    sub _compile_destroy {
        goto \&Mite::Trait::HasDestructor::_compile_destroy;
    }
    sub _compile_does { goto \&Mite::Trait::HasRoles::_compile_does; }

    sub _compile_extends {
        goto \&Mite::Trait::HasSuperclasses::_compile_extends;
    }

    sub _compile_init_attributes {
        goto \&Mite::Trait::HasAttributes::_compile_init_attributes;
    }

    sub _compile_method_signatures {
        goto \&Mite::Trait::HasMethods::_compile_method_signatures;
    }
    sub _compile_mop { goto \&Mite::Trait::HasMOP::_compile_mop; }

    sub _compile_mop_attributes {
        goto \&Mite::Trait::HasMOP::_compile_mop_attributes;
    }

    sub _compile_mop_methods {
        goto \&Mite::Trait::HasMOP::_compile_mop_methods;
    }

    sub _compile_mop_modifiers {
        goto \&Mite::Trait::HasMOP::_compile_mop_modifiers;
    }

    sub _compile_mop_required_methods {
        goto \&Mite::Trait::HasMOP::_compile_mop_required_methods;
    }

    sub _compile_mop_tc {
        goto \&Mite::Trait::HasMOP::_compile_mop_tc;
    }

    sub _compile_new {
        goto \&Mite::Trait::HasConstructor::_compile_new;
    }

    sub _compile_strict_constructor {
        goto
          \&Mite::Trait::HasConstructor::_compile_strict_constructor;
    }
    sub _compile_with { goto \&Mite::Trait::HasRoles::_compile_with; }

    sub _get_parent {
        goto \&Mite::Trait::HasSuperclasses::_get_parent;
    }
    sub _get_role { goto \&Mite::Trait::HasRoles::_get_role; }
    sub _set_isa  { goto \&Mite::Trait::HasSuperclasses::_set_isa; }

    sub _trigger_extends {
        goto \&Mite::Trait::HasSuperclasses::_trigger_extends;
    }

    sub add_attribute {
        goto \&Mite::Trait::HasAttributes::add_attribute;
    }

    sub add_attributes {
        goto \&Mite::Trait::HasAttributes::add_attributes;
    }

    sub add_method_signature {
        goto \&Mite::Trait::HasMethods::add_method_signature;
    }
    sub add_role { goto \&Mite::Trait::HasRoles::add_role; }

    sub add_roles_by_name {
        goto \&Mite::Trait::HasRoles::add_roles_by_name;
    }

    sub all_attributes {
        goto \&Mite::Trait::HasAttributes::all_attributes;
    }
    sub does_list { goto \&Mite::Trait::HasRoles::does_list; }

    sub extend_attribute {
        goto \&Mite::Trait::HasAttributes::extend_attribute;
    }
    sub get_isa { goto \&Mite::Trait::HasSuperclasses::get_isa; }

    sub handle_extends_keyword {
        goto \&Mite::Trait::HasSuperclasses::handle_extends_keyword;
    }

    sub handle_with_keyword {
        goto \&Mite::Trait::HasRoles::handle_with_keyword;
    }
    sub linear_isa {
        goto \&Mite::Trait::HasSuperclasses::linear_isa;
    }

    sub linear_parents {
        goto \&Mite::Trait::HasSuperclasses::linear_parents;
    }

    sub methods_to_import_from_roles {
        goto \&Mite::Trait::HasRoles::methods_to_import_from_roles;
    }

    sub native_methods {
        goto \&Mite::Trait::HasMethods::native_methods;
    }

    1;
}
