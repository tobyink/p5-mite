{

    package Mite::Role;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.010000";

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

        # Attribute required_methods (type: ArrayRef[MethodName])
        # has declaration, file lib/Mite/Trait/HasRequiredMethods.pm, line 14
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

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(
/\A(?:attributes|imported_functions|method_signatures|name|r(?:equired_methods|ole(?:_args|s))|s(?:him_name|ource))\z/
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

    # Accessors for required_methods
    # has declaration, file lib/Mite/Trait/HasRequiredMethods.pm, line 14
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "required_methods" => "required_methods" },
        );
    }
    else {
        *required_methods = sub {
            @_ == 1
              or croak(
                'Reader "required_methods" usage: $self->required_methods()');
            $_[0]{"required_methods"};
        };
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

    BEGIN {
        require Mite::Trait::HasRequiredMethods;
        require Mite::Trait::HasAttributes;
        require Mite::Trait::HasRoles;
        require Mite::Trait::HasMethods;
        require Mite::Trait::HasMOP;

        our %DOES = (
            "Mite::Role"                      => 1,
            "Mite::Trait::HasRequiredMethods" => 1,
            "Mite::Trait::HasAttributes"      => 1,
            "Mite::Trait::HasRoles"           => 1,
            "Mite::Trait::HasMethods"         => 1,
            "Mite::Trait::HasMOP"             => 1
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

    sub _build_required_methods {
        goto
          \&Mite::Trait::HasRequiredMethods::_build_required_methods;
    }

    sub _build_role_args {
        goto \&Mite::Trait::HasRoles::_build_role_args;
    }
    sub _build_roles { goto \&Mite::Trait::HasRoles::_build_roles; }

    sub _compile_attribute_accessors {
        goto
          \&Mite::Trait::HasAttributes::_compile_attribute_accessors;
    }

    sub _compile_composed_methods {
        goto \&Mite::Trait::HasRoles::_compile_composed_methods;
    }
    sub _compile_does { goto \&Mite::Trait::HasRoles::_compile_does; }

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

    sub _compile_mop_postamble {
        goto \&Mite::Trait::HasMOP::_compile_mop_postamble;
    }

    sub _compile_mop_required_methods {
        goto \&Mite::Trait::HasMOP::_compile_mop_required_methods;
    }
    sub _compile_with { goto \&Mite::Trait::HasRoles::_compile_with; }
    sub _get_role     { goto \&Mite::Trait::HasRoles::_get_role; }

    sub _needs_accessors {
        goto \&Mite::Trait::HasAttributes::_needs_accessors;
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

    sub add_required_methods {
        goto \&Mite::Trait::HasRequiredMethods::add_required_methods;
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

    sub handle_with_keyword {
        goto \&Mite::Trait::HasRoles::handle_with_keyword;
    }

    sub methods_to_import_from_roles {
        goto \&Mite::Trait::HasRoles::methods_to_import_from_roles;
    }

    sub native_methods {
        goto \&Mite::Trait::HasMethods::native_methods;
    }

    1;
}
