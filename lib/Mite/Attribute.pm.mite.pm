{

    package Mite::Attribute;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.008003";

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

        # Attribute _order
        # has declaration, file lib/Mite/Attribute.pm, line 18
        $self->{"_order"} = $self->_build__order;

        # Attribute definition_context (type: HashRef)
        # has declaration, file lib/Mite/Attribute.pm, line 20
        do {
            my $value =
              exists( $args->{"definition_context"} )
              ? $args->{"definition_context"}
              : {};
            ( ref($value) eq 'HASH' )
              or croak "Type check failed in constructor: %s should be %s",
              "definition_context", "HashRef";
            $self->{"definition_context"} = $value;
        };

        # Attribute class (type: Mite::Role)
        # has declaration, file lib/Mite/Attribute.pm, line 25
        if ( exists $args->{"class"} ) {
            blessed( $args->{"class"} ) && $args->{"class"}->isa("Mite::Role")
              or croak "Type check failed in constructor: %s should be %s",
              "class", "Mite::Role";
            $self->{"class"} = $args->{"class"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"class"} )
          if ref $self->{"class"};

        # Attribute _class_for_default (type: Mite::Role)
        # has declaration, file lib/Mite/Attribute.pm, line 41
        if ( exists $args->{"_class_for_default"} ) {
            blessed( $args->{"_class_for_default"} )
              && $args->{"_class_for_default"}->isa("Mite::Role")
              or croak "Type check failed in constructor: %s should be %s",
              "_class_for_default", "Mite::Role";
            $self->{"_class_for_default"} = $args->{"_class_for_default"};
        }
        require Scalar::Util
          && Scalar::Util::weaken( $self->{"_class_for_default"} )
          if ref $self->{"_class_for_default"};

        # Attribute name (type: NonEmptyStr)
        # has declaration, file lib/Mite/Attribute.pm, line 43
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
            ) && do { package Mite::Shim; length( $args->{"name"} ) > 0 }
          )
          or croak "Type check failed in constructor: %s should be %s", "name",
          "NonEmptyStr";
        $self->{"name"} = $args->{"name"};

        # Attribute init_arg (type: NonEmptyStr|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 52
        if ( exists $args->{"init_arg"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"init_arg"} ) and do {
                                    ref( \$args->{"init_arg"} ) eq 'SCALAR'
                                      or
                                      ref( \( my $val = $args->{"init_arg"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && do {

                            package Mite::Shim;
                            length( $args->{"init_arg"} ) > 0;
                        }
                    )
                      or
                      do { package Mite::Shim; !defined( $args->{"init_arg"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "init_arg", "NonEmptyStr|Undef";
            $self->{"init_arg"} = $args->{"init_arg"};
        }

        # Attribute required (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 54
        do {
            my $value = exists( $args->{"required"} )
              ? do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"required"};
                    (
                        (
                            !ref $to_coerce
                              and (!defined $to_coerce
                                or $to_coerce eq q()
                                or $to_coerce eq '0'
                                or $to_coerce eq '1' )
                        )
                      ) ? $to_coerce
                      : ( ( !!1 ) )
                      ? scalar( do { local $_ = $to_coerce; !!$_ } )
                      : $to_coerce;
                };
                (
                    (
                        !ref $coerced_value
                          and (!defined $coerced_value
                            or $coerced_value eq q()
                            or $coerced_value eq '0'
                            or $coerced_value eq '1' )
                    )
                  )
                  ? $coerced_value
                  : croak( "Type check failed in constructor: %s should be %s",
                    "required", "Bool" );
              }
              : false;
            $self->{"required"} = $value;
        };

        # Attribute weak_ref (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 61
        do {
            my $value =
              exists( $args->{"weak_ref"} ) ? $args->{"weak_ref"} : false;
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "weak_ref", "Bool";
            $self->{"weak_ref"} = $value;
        };

        # Attribute is (type: Enum["ro","rw","rwp","lazy","bare"])
        # has declaration, file lib/Mite/Attribute.pm, line 66
        do {
            my $value = exists( $args->{"is"} ) ? $args->{"is"} : "bare";
            do {

                package Mite::Shim;
                (         defined($value)
                      and !ref($value)
                      and $value =~ m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z} );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "is", "Enum[\"ro\",\"rw\",\"rwp\",\"lazy\",\"bare\"]";
            $self->{"is"} = $value;
        };

        # Attribute reader (type: MethodNameTemplate|One|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 71
        if ( exists $args->{"reader"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"reader"} ) and do {
                                            ref( \$args->{"reader"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"reader"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"reader"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"reader"} ) and do {
                                            ref( \$args->{"reader"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"reader"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"reader"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"reader"} )
                              and !ref( $args->{"reader"} )
                              and $args->{"reader"} =~ m{\A(?:1)\z} );
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"reader"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "reader", "MethodNameTemplate|One|Undef";
            $self->{"reader"} = $args->{"reader"};
        }

        # Attribute writer (type: MethodNameTemplate|One|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 71
        if ( exists $args->{"writer"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"writer"} ) and do {
                                            ref( \$args->{"writer"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"writer"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"writer"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"writer"} ) and do {
                                            ref( \$args->{"writer"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"writer"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"writer"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"writer"} )
                              and !ref( $args->{"writer"} )
                              and $args->{"writer"} =~ m{\A(?:1)\z} );
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"writer"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "writer", "MethodNameTemplate|One|Undef";
            $self->{"writer"} = $args->{"writer"};
        }

        # Attribute accessor (type: MethodNameTemplate|One|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 71
        if ( exists $args->{"accessor"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"accessor"} ) and do {
                                            ref( \$args->{"accessor"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val =
                                                      $args->{"accessor"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"accessor"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"accessor"} ) and do {
                                            ref( \$args->{"accessor"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val =
                                                      $args->{"accessor"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"accessor"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"accessor"} )
                              and !ref( $args->{"accessor"} )
                              and $args->{"accessor"} =~ m{\A(?:1)\z} );
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"accessor"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "accessor", "MethodNameTemplate|One|Undef";
            $self->{"accessor"} = $args->{"accessor"};
        }

        # Attribute clearer (type: MethodNameTemplate|One|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 71
        if ( exists $args->{"clearer"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"clearer"} ) and do {
                                            ref( \$args->{"clearer"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"clearer"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"clearer"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"clearer"} ) and do {
                                            ref( \$args->{"clearer"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"clearer"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"clearer"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"clearer"} )
                              and !ref( $args->{"clearer"} )
                              and $args->{"clearer"} =~ m{\A(?:1)\z} );
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"clearer"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "clearer", "MethodNameTemplate|One|Undef";
            $self->{"clearer"} = $args->{"clearer"};
        }

        # Attribute predicate (type: MethodNameTemplate|One|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 71
        if ( exists $args->{"predicate"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"predicate"} ) and do {
                                            ref( \$args->{"predicate"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val =
                                                      $args->{"predicate"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"predicate"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"predicate"} ) and do {
                                            ref( \$args->{"predicate"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val =
                                                      $args->{"predicate"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"predicate"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"predicate"} )
                              and !ref( $args->{"predicate"} )
                              and $args->{"predicate"} =~ m{\A(?:1)\z} );
                      }
                      or do {

                        package Mite::Shim;
                        !defined( $args->{"predicate"} );
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "predicate", "MethodNameTemplate|One|Undef";
            $self->{"predicate"} = $args->{"predicate"};
        }

        # Attribute lvalue (type: MethodNameTemplate|One|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 71
        if ( exists $args->{"lvalue"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"lvalue"} ) and do {
                                            ref( \$args->{"lvalue"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"lvalue"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"lvalue"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"lvalue"} ) and do {
                                            ref( \$args->{"lvalue"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"lvalue"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"lvalue"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"lvalue"} )
                              and !ref( $args->{"lvalue"} )
                              and $args->{"lvalue"} =~ m{\A(?:1)\z} );
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"lvalue"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "lvalue", "MethodNameTemplate|One|Undef";
            $self->{"lvalue"} = $args->{"lvalue"};
        }

        # Attribute local_writer (type: MethodNameTemplate|One|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 71
        if ( exists $args->{"local_writer"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"local_writer"} )
                                          and do {
                                            ref( \$args->{"local_writer"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val =
                                                      $args->{"local_writer"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"local_writer"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"local_writer"} )
                                          and do {
                                            ref( \$args->{"local_writer"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val =
                                                      $args->{"local_writer"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do {
                                        local $_ = $args->{"local_writer"};
                                        /\%/;
                                    }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"local_writer"} )
                              and !ref( $args->{"local_writer"} )
                              and $args->{"local_writer"} =~ m{\A(?:1)\z} );
                      }
                      or do {

                        package Mite::Shim;
                        !defined( $args->{"local_writer"} );
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "local_writer", "MethodNameTemplate|One|Undef";
            $self->{"local_writer"} = $args->{"local_writer"};
        }

        # Attribute isa (type: Str|Ref)
        # has declaration, file lib/Mite/Attribute.pm, line 77
        if ( exists $args->{"isa"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        defined( $args->{"isa"} ) and do {
                            ref( \$args->{"isa"} ) eq 'SCALAR'
                              or ref( \( my $val = $args->{"isa"} ) ) eq
                              'SCALAR';
                        }
                      }
                      or do { package Mite::Shim; !!ref( $args->{"isa"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "isa", "Str|Ref";
            $self->{"isa"} = $args->{"isa"};
        }

        # Attribute does (type: Str|Ref)
        # has declaration, file lib/Mite/Attribute.pm, line 82
        if ( exists $args->{"does"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        defined( $args->{"does"} ) and do {
                            ref( \$args->{"does"} ) eq 'SCALAR'
                              or ref( \( my $val = $args->{"does"} ) ) eq
                              'SCALAR';
                        }
                      }
                      or do { package Mite::Shim; !!ref( $args->{"does"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "does", "Str|Ref";
            $self->{"does"} = $args->{"does"};
        }

        # Attribute enum (type: ArrayRef[NonEmptyStr])
        # has declaration, file lib/Mite/Attribute.pm, line 87
        if ( exists $args->{"enum"} ) {
            (
                do { package Mite::Shim; ref( $args->{"enum"} ) eq 'ARRAY' }
                  and do {
                    my $ok = 1;
                    for my $i ( @{ $args->{"enum"} } ) {
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
                            && ( length($i) > 0 )
                          );
                    };
                    $ok;
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "enum", "ArrayRef[NonEmptyStr]";
            $self->{"enum"} = $args->{"enum"};
        }

        # Attribute type (type: Object|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 92
        if ( exists $args->{"type"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        do {

                            package Mite::Shim;
                            use Scalar::Util ();
                            Scalar::Util::blessed( $args->{"type"} );
                        }
                    ) or do { package Mite::Shim; !defined( $args->{"type"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "type", "Object|Undef";
            $self->{"type"} = $args->{"type"};
        }

        # Attribute coerce (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 97
        do {
            my $value = exists( $args->{"coerce"} ) ? $args->{"coerce"} : false;
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "coerce", "Bool";
            $self->{"coerce"} = $value;
        };

        # Attribute default (type: Undef|Str|CodeRef|ScalarRef|Dict[]|Tuple[])
        # has declaration, file lib/Mite/Attribute.pm, line 102
        if ( exists $args->{"default"} ) {
            do {

                package Mite::Shim;
                (
                    do { package Mite::Shim; !defined( $args->{"default"} ) }
                      or do {

                        package Mite::Shim;
                        defined( $args->{"default"} ) and do {
                            ref( \$args->{"default"} ) eq 'SCALAR'
                              or ref( \( my $val = $args->{"default"} ) ) eq
                              'SCALAR';
                        }
                      }
                      or do {

                        package Mite::Shim;
                        ref( $args->{"default"} ) eq 'CODE';
                      }
                      or do {

                        package Mite::Shim;
                        ref( $args->{"default"} ) eq 'SCALAR'
                          or ref( $args->{"default"} ) eq 'REF';
                      }
                      or do {

                        package Mite::Shim;
                        do {

                            package Mite::Shim;
                            ref( $args->{"default"} ) eq 'HASH';
                          }
                          and
                          not( grep !/\A(?:)\z/, keys %{ $args->{"default"} } );
                      }
                      or do {

                        package Mite::Shim;
                        do {

                            package Mite::Shim;
                            ref( $args->{"default"} ) eq 'ARRAY';
                          }
                          and @{ $args->{"default"} } == 0;
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "default", "Undef|Str|CodeRef|ScalarRef|Dict[]|Tuple[]";
            $self->{"default"} = $args->{"default"};
        }

        # Attribute default_is_trusted (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 108
        do {
            my $value = exists( $args->{"default_is_trusted"} )
              ? do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"default_is_trusted"};
                    (
                        (
                            !ref $to_coerce
                              and (!defined $to_coerce
                                or $to_coerce eq q()
                                or $to_coerce eq '0'
                                or $to_coerce eq '1' )
                        )
                      ) ? $to_coerce
                      : ( ( !!1 ) )
                      ? scalar( do { local $_ = $to_coerce; !!$_ } )
                      : $to_coerce;
                };
                (
                    (
                        !ref $coerced_value
                          and (!defined $coerced_value
                            or $coerced_value eq q()
                            or $coerced_value eq '0'
                            or $coerced_value eq '1' )
                    )
                  )
                  ? $coerced_value
                  : croak( "Type check failed in constructor: %s should be %s",
                    "default_is_trusted", "Bool" );
              }
              : false;
            $self->{"default_is_trusted"} = $value;
        };

        # Attribute default_does_trigger (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 108
        do {
            my $value = exists( $args->{"default_does_trigger"} )
              ? do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"default_does_trigger"};
                    (
                        (
                            !ref $to_coerce
                              and (!defined $to_coerce
                                or $to_coerce eq q()
                                or $to_coerce eq '0'
                                or $to_coerce eq '1' )
                        )
                      ) ? $to_coerce
                      : ( ( !!1 ) )
                      ? scalar( do { local $_ = $to_coerce; !!$_ } )
                      : $to_coerce;
                };
                (
                    (
                        !ref $coerced_value
                          and (!defined $coerced_value
                            or $coerced_value eq q()
                            or $coerced_value eq '0'
                            or $coerced_value eq '1' )
                    )
                  )
                  ? $coerced_value
                  : croak( "Type check failed in constructor: %s should be %s",
                    "default_does_trigger", "Bool" );
              }
              : false;
            $self->{"default_does_trigger"} = $value;
        };

        # Attribute skip_argc_check (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 108
        do {
            my $value = exists( $args->{"skip_argc_check"} )
              ? do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"skip_argc_check"};
                    (
                        (
                            !ref $to_coerce
                              and (!defined $to_coerce
                                or $to_coerce eq q()
                                or $to_coerce eq '0'
                                or $to_coerce eq '1' )
                        )
                      ) ? $to_coerce
                      : ( ( !!1 ) )
                      ? scalar( do { local $_ = $to_coerce; !!$_ } )
                      : $to_coerce;
                };
                (
                    (
                        !ref $coerced_value
                          and (!defined $coerced_value
                            or $coerced_value eq q()
                            or $coerced_value eq '0'
                            or $coerced_value eq '1' )
                    )
                  )
                  ? $coerced_value
                  : croak( "Type check failed in constructor: %s should be %s",
                    "skip_argc_check", "Bool" );
              }
              : false;
            $self->{"skip_argc_check"} = $value;
        };

        # Attribute lazy (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 115
        do {
            my $value = exists( $args->{"lazy"} ) ? $args->{"lazy"} : false;
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "lazy", "Bool";
            $self->{"lazy"} = $value;
        };

        # Attribute coderef_default_variable (type: NonEmptyStr)
        # has declaration, file lib/Mite/Attribute.pm, line 127
        if ( exists $args->{"coderef_default_variable"} ) {
            (
                (
                    do {

                        package Mite::Shim;
                        defined( $args->{"coderef_default_variable"} ) and do {
                            ref( \$args->{"coderef_default_variable"} ) eq
                              'SCALAR'
                              or ref(
                                \(
                                    my $val =
                                      $args->{"coderef_default_variable"}
                                )
                              ) eq 'SCALAR';
                        }
                    }
                )
                  && do {

                    package Mite::Shim;
                    length( $args->{"coderef_default_variable"} ) > 0;
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "coderef_default_variable", "NonEmptyStr";
            $self->{"coderef_default_variable"} =
              $args->{"coderef_default_variable"};
        }

        # Attribute trigger (type: MethodNameTemplate|One|CodeRef)
        # has declaration, file lib/Mite/Attribute.pm, line 129
        if ( exists $args->{"trigger"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"trigger"} ) and do {
                                            ref( \$args->{"trigger"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"trigger"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"trigger"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"trigger"} ) and do {
                                            ref( \$args->{"trigger"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"trigger"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"trigger"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"trigger"} )
                              and !ref( $args->{"trigger"} )
                              and $args->{"trigger"} =~ m{\A(?:1)\z} );
                      }
                      or do {

                        package Mite::Shim;
                        ref( $args->{"trigger"} ) eq 'CODE';
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "trigger", "MethodNameTemplate|One|CodeRef";
            $self->{"trigger"} = $args->{"trigger"};
        }

        # Attribute builder (type: MethodNameTemplate|One|CodeRef)
        # has declaration, file lib/Mite/Attribute.pm, line 129
        if ( exists $args->{"builder"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"builder"} ) and do {
                                            ref( \$args->{"builder"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"builder"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"builder"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"builder"} ) and do {
                                            ref( \$args->{"builder"} ) eq
                                              'SCALAR'
                                              or ref(
                                                \(
                                                    my $val = $args->{"builder"}
                                                )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"builder"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"builder"} )
                              and !ref( $args->{"builder"} )
                              and $args->{"builder"} =~ m{\A(?:1)\z} );
                      }
                      or do {

                        package Mite::Shim;
                        ref( $args->{"builder"} ) eq 'CODE';
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "builder", "MethodNameTemplate|One|CodeRef";
            $self->{"builder"} = $args->{"builder"};
        }

        # Attribute clone (type: MethodNameTemplate|One|CodeRef|Undef)
        # has declaration, file lib/Mite/Attribute.pm, line 134
        if ( exists $args->{"clone"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"clone"} ) and do {
                                            ref( \$args->{"clone"} ) eq 'SCALAR'
                                              or ref(
                                                \( my $val = $args->{"clone"} )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do {
                                        local $_ = $args->{"clone"};
                                        /\A[^\W0-9]\w*\z/;
                                    }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $args->{"clone"} ) and do {
                                            ref( \$args->{"clone"} ) eq 'SCALAR'
                                              or ref(
                                                \( my $val = $args->{"clone"} )
                                              ) eq 'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $args->{"clone"}; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $args->{"clone"} )
                              and !ref( $args->{"clone"} )
                              and $args->{"clone"} =~ m{\A(?:1)\z} );
                      }
                      or do {

                        package Mite::Shim;
                        ref( $args->{"clone"} ) eq 'CODE';
                      }
                      or do { package Mite::Shim; !defined( $args->{"clone"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "clone", "MethodNameTemplate|One|CodeRef|Undef";
            $self->{"clone"} = $args->{"clone"};
        }

        # Attribute clone_on_read (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 143
        if ( exists $args->{"clone_on_read"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"clone_on_read"};
                    (
                        (
                            !ref $to_coerce
                              and (!defined $to_coerce
                                or $to_coerce eq q()
                                or $to_coerce eq '0'
                                or $to_coerce eq '1' )
                        )
                      ) ? $to_coerce
                      : ( ( !!1 ) )
                      ? scalar( do { local $_ = $to_coerce; !!$_ } )
                      : $to_coerce;
                };
                (
                    !ref $coerced_value
                      and (!defined $coerced_value
                        or $coerced_value eq q()
                        or $coerced_value eq '0'
                        or $coerced_value eq '1' )
                  )
                  or croak "Type check failed in constructor: %s should be %s",
                  "clone_on_read", "Bool";
                $self->{"clone_on_read"} = $coerced_value;
            };
        }

        # Attribute clone_on_write (type: Bool)
        # has declaration, file lib/Mite/Attribute.pm, line 143
        if ( exists $args->{"clone_on_write"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"clone_on_write"};
                    (
                        (
                            !ref $to_coerce
                              and (!defined $to_coerce
                                or $to_coerce eq q()
                                or $to_coerce eq '0'
                                or $to_coerce eq '1' )
                        )
                      ) ? $to_coerce
                      : ( ( !!1 ) )
                      ? scalar( do { local $_ = $to_coerce; !!$_ } )
                      : $to_coerce;
                };
                (
                    !ref $coerced_value
                      and (!defined $coerced_value
                        or $coerced_value eq q()
                        or $coerced_value eq '0'
                        or $coerced_value eq '1' )
                  )
                  or croak "Type check failed in constructor: %s should be %s",
                  "clone_on_write", "Bool";
                $self->{"clone_on_write"} = $coerced_value;
            };
        }

        # Attribute documentation
        # has declaration, file lib/Mite/Attribute.pm, line 145
        if ( exists $args->{"documentation"} ) {
            $self->{"documentation"} = $args->{"documentation"};
        }

        # Attribute handles (type: HandlesHash|Enum["1","2"])
        # has declaration, file lib/Mite/Attribute.pm, line 149
        if ( exists $args->{"handles"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"handles"};
                    (
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    ( ref($to_coerce) eq 'HASH' ) and do {
                                        my $ok = 1;
                                        for my $v ( values %{$to_coerce} ) {
                                            ( $ok = 0, last )
                                              unless (
                                                (
                                                    do {

                                                        package Mite::Shim;
                                                        defined($v) and do {
                                                            ref( \$v ) eq
                                                              'SCALAR'
                                                              or ref(
                                                                \(
                                                                    my $val =
                                                                      $v
                                                                )
                                                              ) eq 'SCALAR';
                                                        }
                                                    }
                                                )
                                                && (
                                                    do {
                                                        local $_ = $v;
                                                        /\A[^\W0-9]\w*\z/;
                                                    }
                                                )
                                              );
                                        };
                                        for my $k ( keys %{$to_coerce} ) {
                                            ( $ok = 0, last ) unless do {

                                                package Mite::Shim;
                                                (
                                                    (
                                                        (
                                                            do {

                                                                package Mite::Shim;
                                                                defined($k)
                                                                  and do {
                                                                    ref( \$k )
                                                                      eq
                                                                      'SCALAR'
                                                                      or ref(
                                                                        \(
                                                                            my $val
                                                                              = $k
                                                                        )
                                                                      ) eq
                                                                      'SCALAR';
                                                                }
                                                            }
                                                        )
                                                          && (
                                                            do {
                                                                local $_ = $k;
/\A[^\W0-9]\w*\z/;
                                                            }
                                                          )
                                                    )
                                                      or (
                                                        (
                                                            do {

                                                                package Mite::Shim;
                                                                defined($k)
                                                                  and do {
                                                                    ref( \$k )
                                                                      eq
                                                                      'SCALAR'
                                                                      or ref(
                                                                        \(
                                                                            my $val
                                                                              = $k
                                                                        )
                                                                      ) eq
                                                                      'SCALAR';
                                                                }
                                                            }
                                                        )
                                                        && (
                                                            do {
                                                                local $_ = $k;
                                                                /\%/;
                                                            }
                                                        )
                                                      )
                                                );
                                            }
                                        };
                                        $ok;
                                    }
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($to_coerce)
                                          and !ref($to_coerce)
                                          and $to_coerce =~ m{\A(?:[12])\z} );
                                }
                            );
                        }
                      )
                      ? $to_coerce
                      : ( ( ref($to_coerce) eq 'ARRAY' ) ) ? scalar(
                        do {
                            local $_ = $to_coerce;
                            +{ map { $_ => $_ } @$_ };
                        }
                      )
                      : $to_coerce;
                };
                do {

                    package Mite::Shim;
                    (
                        do {

                            package Mite::Shim;
                            ( ref($coerced_value) eq 'HASH' ) and do {
                                my $ok = 1;
                                for my $v ( values %{$coerced_value} ) {
                                    ( $ok = 0, last )
                                      unless (
                                        (
                                            do {

                                                package Mite::Shim;
                                                defined($v) and do {
                                                    ref( \$v ) eq 'SCALAR'
                                                      or
                                                      ref( \( my $val = $v ) )
                                                      eq 'SCALAR';
                                                }
                                            }
                                        )
                                        && (
                                            do {
                                                local $_ = $v;
                                                /\A[^\W0-9]\w*\z/;
                                            }
                                        )
                                      );
                                };
                                for my $k ( keys %{$coerced_value} ) {
                                    ( $ok = 0, last ) unless do {

                                        package Mite::Shim;
                                        (
                                            (
                                                (
                                                    do {

                                                        package Mite::Shim;
                                                        defined($k) and do {
                                                            ref( \$k ) eq
                                                              'SCALAR'
                                                              or ref(
                                                                \(
                                                                    my $val =
                                                                      $k
                                                                )
                                                              ) eq 'SCALAR';
                                                        }
                                                    }
                                                )
                                                  && (
                                                    do {
                                                        local $_ = $k;
                                                        /\A[^\W0-9]\w*\z/;
                                                    }
                                                  )
                                            )
                                              or (
                                                (
                                                    do {

                                                        package Mite::Shim;
                                                        defined($k) and do {
                                                            ref( \$k ) eq
                                                              'SCALAR'
                                                              or ref(
                                                                \(
                                                                    my $val =
                                                                      $k
                                                                )
                                                              ) eq 'SCALAR';
                                                        }
                                                    }
                                                )
                                                && ( do { local $_ = $k; /\%/ }
                                                )
                                              )
                                        );
                                    }
                                };
                                $ok;
                            }
                          }
                          or do {

                            package Mite::Shim;
                            (         defined($coerced_value)
                                  and !ref($coerced_value)
                                  and $coerced_value =~ m{\A(?:[12])\z} );
                        }
                    );
                  }
                  or croak "Type check failed in constructor: %s should be %s",
                  "handles", "HandlesHash|Enum[\"1\",\"2\"]";
                $self->{"handles"} = $coerced_value;
            };
        }

        # Attribute handles_via (type: ArrayRef[Str])
        # has declaration, file lib/Mite/Attribute.pm, line 155
        if ( exists $args->{"handles_via"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"handles_via"};
                    (
                        do {

                            package Mite::Shim;
                            ( ref($to_coerce) eq 'ARRAY' ) and do {
                                my $ok = 1;
                                for my $i ( @{$to_coerce} ) {
                                    ( $ok = 0, last ) unless do {

                                        package Mite::Shim;
                                        defined($i) and do {
                                            ref( \$i ) eq 'SCALAR'
                                              or ref( \( my $val = $i ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                };
                                $ok;
                            }
                        }
                    ) ? $to_coerce : (
                        do {

                            package Mite::Shim;
                            defined($to_coerce) and do {
                                ref( \$to_coerce ) eq 'SCALAR'
                                  or ref( \( my $val = $to_coerce ) ) eq
                                  'SCALAR';
                            }
                        }
                      )
                      ? scalar( do { local $_ = $to_coerce; [$_] } )
                      : $to_coerce;
                };
                do {

                    package Mite::Shim;
                    ( ref($coerced_value) eq 'ARRAY' ) and do {
                        my $ok = 1;
                        for my $i ( @{$coerced_value} ) {
                            ( $ok = 0, last ) unless do {

                                package Mite::Shim;
                                defined($i) and do {
                                    ref( \$i ) eq 'SCALAR'
                                      or ref( \( my $val = $i ) ) eq 'SCALAR';
                                }
                            }
                        };
                        $ok;
                    }
                  }
                  or croak "Type check failed in constructor: %s should be %s",
                  "handles_via", "ArrayRef[Str]";
                $self->{"handles_via"} = $coerced_value;
            };
        }

        # Attribute alias (type: AliasList)
        # has declaration, file lib/Mite/Attribute.pm, line 165
        do {
            my $value =
              exists( $args->{"alias"} )
              ? $args->{"alias"}
              : $Mite::Attribute::__alias_DEFAULT__->($self);
            do {
                my $coerced_value = do {
                    my $to_coerce = $value;
                    (
                        do {

                            package Mite::Shim;
                            ( ref($to_coerce) eq 'ARRAY' ) and do {
                                my $ok = 1;
                                for my $i ( @{$to_coerce} ) {
                                    ( $ok = 0, last ) unless do {

                                        package Mite::Shim;
                                        (
                                            (
                                                (
                                                    do {

                                                        package Mite::Shim;
                                                        defined($i) and do {
                                                            ref( \$i ) eq
                                                              'SCALAR'
                                                              or ref(
                                                                \(
                                                                    my $val =
                                                                      $i
                                                                )
                                                              ) eq 'SCALAR';
                                                        }
                                                    }
                                                )
                                                  && (
                                                    do {
                                                        local $_ = $i;
                                                        /\A[^\W0-9]\w*\z/;
                                                    }
                                                  )
                                            )
                                              or (
                                                (
                                                    do {

                                                        package Mite::Shim;
                                                        defined($i) and do {
                                                            ref( \$i ) eq
                                                              'SCALAR'
                                                              or ref(
                                                                \(
                                                                    my $val =
                                                                      $i
                                                                )
                                                              ) eq 'SCALAR';
                                                        }
                                                    }
                                                )
                                                && ( do { local $_ = $i; /\%/ }
                                                )
                                              )
                                        );
                                    }
                                };
                                $ok;
                            }
                        }
                    ) ? $to_coerce : (
                        do {

                            package Mite::Shim;
                            defined($to_coerce) and do {
                                ref( \$to_coerce ) eq 'SCALAR'
                                  or ref( \( my $val = $to_coerce ) ) eq
                                  'SCALAR';
                            }
                        }
                    ) ? scalar( do { local $_ = $to_coerce; [$_] } )
                      : ( ( !defined($to_coerce) ) )
                      ? scalar( do { local $_ = $to_coerce; [] } )
                      : $to_coerce;
                };
                do {

                    package Mite::Shim;
                    ( ref($coerced_value) eq 'ARRAY' ) and do {
                        my $ok = 1;
                        for my $i ( @{$coerced_value} ) {
                            ( $ok = 0, last ) unless do {

                                package Mite::Shim;
                                (
                                    (
                                        (
                                            do {

                                                package Mite::Shim;
                                                defined($i) and do {
                                                    ref( \$i ) eq 'SCALAR'
                                                      or
                                                      ref( \( my $val = $i ) )
                                                      eq 'SCALAR';
                                                }
                                            }
                                        )
                                          && (
                                            do {
                                                local $_ = $i;
                                                /\A[^\W0-9]\w*\z/;
                                            }
                                          )
                                    )
                                      or (
                                        (
                                            do {

                                                package Mite::Shim;
                                                defined($i) and do {
                                                    ref( \$i ) eq 'SCALAR'
                                                      or
                                                      ref( \( my $val = $i ) )
                                                      eq 'SCALAR';
                                                }
                                            }
                                        )
                                        && ( do { local $_ = $i; /\%/ } )
                                      )
                                );
                            }
                        };
                        $ok;
                    }
                  }
                  or croak "Type check failed in constructor: %s should be %s",
                  "alias", "AliasList";
                $self->{"alias"} = $coerced_value;
            };
        };

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(
/\A(?:_class_for_default|a(?:ccessor|lias)|builder|c(?:l(?:ass|earer|one(?:_on_(?:read|write))?)|o(?:deref_default_variable|erce))|d(?:ef(?:ault(?:_(?:does_trigger|is_trusted))?|inition_context)|o(?:cumentation|es))|enum|handles(?:_via)?|i(?:nit_arg|sa?)|l(?:azy|ocal_writer|value)|name|predicate|re(?:ader|quired)|skip_argc_check|t(?:rigger|ype)|w(?:eak_ref|riter))\z/
        ), keys %{$args};
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

    # Accessors for _class_for_default
    # has declaration, file lib/Mite/Attribute.pm, line 41
    sub _class_for_default {
        @_ > 1
          ? do {
            blessed( $_[1] ) && $_[1]->isa("Mite::Role")
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Role" );
            $_[0]{"_class_for_default"} = $_[1];
            require Scalar::Util
              && Scalar::Util::weaken( $_[0]{"_class_for_default"} )
              if ref $_[0]{"_class_for_default"};
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"_class_for_default"} )
                ? $_[0]{"_class_for_default"}
                : (
                    $_[0]{"_class_for_default"} = do {
                        my $default_value = $_[0]->_build__class_for_default;
                        blessed($default_value)
                          && $default_value->isa("Mite::Role")
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "_class_for_default", "Mite::Role" );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for _order
    # has declaration, file lib/Mite/Attribute.pm, line 18
    if ($__XS) {
        Class::XSAccessor->import(
            chained     => 1,
            "accessors" => { "_order" => "_order" },
        );
    }
    else {
        *_order = sub {
            @_ > 1
              ? do { $_[0]{"_order"} = $_[1]; $_[0]; }
              : ( $_[0]{"_order"} );
        };
    }

    # Accessors for accessor
    # has declaration, file lib/Mite/Attribute.pm, line 71
    sub accessor {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|Undef" );
            $_[0]{"accessor"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"accessor"} ) ? $_[0]{"accessor"} : (
                    $_[0]{"accessor"} = do {
                        my $default_value = $_[0]->_build_accessor;
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\%/;
                                                }
                                            )
                                          )
                                    );
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($default_value)
                                          and !ref($default_value)
                                          and $default_value =~ m{\A(?:1)\z} );
                                  }
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "accessor",
                            "MethodNameTemplate|One|Undef"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for alias
    # has declaration, file lib/Mite/Attribute.pm, line 165
    sub alias {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    do {

                        package Mite::Shim;
                        ( ref($to_coerce) eq 'ARRAY' ) and do {
                            my $ok = 1;
                            for my $i ( @{$to_coerce} ) {
                                ( $ok = 0, last ) unless do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($i) and do {
                                                        ref( \$i ) eq 'SCALAR'
                                                          or ref(
                                                            \( my $val = $i ) )
                                                          eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $i;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($i) and do {
                                                        ref( \$i ) eq 'SCALAR'
                                                          or ref(
                                                            \( my $val = $i ) )
                                                          eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && ( do { local $_ = $i; /\%/ } )
                                          )
                                    );
                                }
                            };
                            $ok;
                        }
                    }
                ) ? $to_coerce : (
                    do {

                        package Mite::Shim;
                        defined($to_coerce) and do {
                            ref( \$to_coerce ) eq 'SCALAR'
                              or ref( \( my $val = $to_coerce ) ) eq 'SCALAR';
                        }
                    }
                ) ? scalar( do { local $_ = $to_coerce; [$_] } )
                  : ( ( !defined($to_coerce) ) )
                  ? scalar( do { local $_ = $to_coerce; [] } )
                  : $to_coerce;
            };
            do {

                package Mite::Shim;
                ( ref($value) eq 'ARRAY' ) and do {
                    my $ok = 1;
                    for my $i ( @{$value} ) {
                        ( $ok = 0, last ) unless do {

                            package Mite::Shim;
                            (
                                (
                                    (
                                        do {

                                            package Mite::Shim;
                                            defined($i) and do {
                                                ref( \$i ) eq 'SCALAR'
                                                  or ref( \( my $val = $i ) )
                                                  eq 'SCALAR';
                                            }
                                        }
                                    )
                                      && (
                                        do { local $_ = $i; /\A[^\W0-9]\w*\z/ }
                                      )
                                )
                                  or (
                                    (
                                        do {

                                            package Mite::Shim;
                                            defined($i) and do {
                                                ref( \$i ) eq 'SCALAR'
                                                  or ref( \( my $val = $i ) )
                                                  eq 'SCALAR';
                                            }
                                        }
                                    )
                                    && ( do { local $_ = $i; /\%/ } )
                                  )
                            );
                        }
                    };
                    $ok;
                }
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "AliasList" );
            $_[0]{"alias"} = $value;
            $_[0];
          }
          : ( $_[0]{"alias"} );
    }

    # Accessors for alias_is_for
    # has declaration, file lib/Mite/Attribute.pm, line 167
    sub alias_is_for {
        @_ == 1 or croak('Reader "alias_is_for" usage: $self->alias_is_for()');
        (
            exists( $_[0]{"alias_is_for"} )
            ? $_[0]{"alias_is_for"}
            : ( $_[0]{"alias_is_for"} = $_[0]->_build_alias_is_for ) );
    }

    # Accessors for builder
    # has declaration, file lib/Mite/Attribute.pm, line 129
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_builder" => "builder" },
        );
    }
    else {
        *has_builder = sub {
            @_ == 1
              or croak('Predicate "has_builder" usage: $self->has_builder()');
            exists $_[0]{"builder"};
        };
    }

    sub builder {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( ref( $_[1] ) eq 'CODE' )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|CodeRef" );
            $_[0]{"builder"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"builder"} );
    }

    # Accessors for class
    # has declaration, file lib/Mite/Attribute.pm, line 25
    sub class {
        @_ > 1
          ? do {
            blessed( $_[1] ) && $_[1]->isa("Mite::Role")
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Role" );
            $_[0]{"class"} = $_[1];
            require Scalar::Util && Scalar::Util::weaken( $_[0]{"class"} )
              if ref $_[0]{"class"};
            $_[0];
          }
          : ( $_[0]{"class"} );
    }

    # Accessors for clearer
    # has declaration, file lib/Mite/Attribute.pm, line 71
    sub clearer {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|Undef" );
            $_[0]{"clearer"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"clearer"} ) ? $_[0]{"clearer"} : (
                    $_[0]{"clearer"} = do {
                        my $default_value = $_[0]->_build_clearer;
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\%/;
                                                }
                                            )
                                          )
                                    );
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($default_value)
                                          and !ref($default_value)
                                          and $default_value =~ m{\A(?:1)\z} );
                                  }
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "clearer",
                            "MethodNameTemplate|One|Undef"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for clone
    # has declaration, file lib/Mite/Attribute.pm, line 134
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "cloner_method" => "clone" },
        );
    }
    else {
        *cloner_method = sub {
            @_ == 1
              or croak('Reader "cloner_method" usage: $self->cloner_method()');
            $_[0]{"clone"};
        };
    }

    # Accessors for clone_on_read
    # has declaration, file lib/Mite/Attribute.pm, line 143
    sub clone_on_read {
        @_ == 1
          or croak('Reader "clone_on_read" usage: $self->clone_on_read()');
        (
            exists( $_[0]{"clone_on_read"} ) ? $_[0]{"clone_on_read"} : (
                $_[0]{"clone_on_read"} = do {
                    my $default_value = do {
                        my $to_coerce = $_[0]->_build_clone_on_read;
                        (
                            (
                                !ref $to_coerce
                                  and (!defined $to_coerce
                                    or $to_coerce eq q()
                                    or $to_coerce eq '0'
                                    or $to_coerce eq '1' )
                            )
                          ) ? $to_coerce
                          : ( ( !!1 ) )
                          ? scalar( do { local $_ = $to_coerce; !!$_ } )
                          : $to_coerce;
                    };
                    (
                        !ref $default_value
                          and (!defined $default_value
                            or $default_value eq q()
                            or $default_value eq '0'
                            or $default_value eq '1' )
                      )
                      or croak( "Type check failed in default: %s should be %s",
                        "clone_on_read", "Bool" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for clone_on_write
    # has declaration, file lib/Mite/Attribute.pm, line 143
    sub clone_on_write {
        @_ == 1
          or croak('Reader "clone_on_write" usage: $self->clone_on_write()');
        (
            exists( $_[0]{"clone_on_write"} ) ? $_[0]{"clone_on_write"} : (
                $_[0]{"clone_on_write"} = do {
                    my $default_value = do {
                        my $to_coerce = $_[0]->_build_clone_on_write;
                        (
                            (
                                !ref $to_coerce
                                  and (!defined $to_coerce
                                    or $to_coerce eq q()
                                    or $to_coerce eq '0'
                                    or $to_coerce eq '1' )
                            )
                          ) ? $to_coerce
                          : ( ( !!1 ) )
                          ? scalar( do { local $_ = $to_coerce; !!$_ } )
                          : $to_coerce;
                    };
                    (
                        !ref $default_value
                          and (!defined $default_value
                            or $default_value eq q()
                            or $default_value eq '0'
                            or $default_value eq '1' )
                      )
                      or croak( "Type check failed in default: %s should be %s",
                        "clone_on_write", "Bool" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for coderef_default_variable
    # has declaration, file lib/Mite/Attribute.pm, line 127
    sub coderef_default_variable {
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
                  && ( length( $_[1] ) > 0 )
              )
              or croak(
                "Type check failed in %s: value should be %s",
                "accessor",
                "NonEmptyStr"
              );
            $_[0]{"coderef_default_variable"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"coderef_default_variable"} )
                ? $_[0]{"coderef_default_variable"}
                : (
                    $_[0]{"coderef_default_variable"} = do {
                        my $default_value =
                          $Mite::Attribute::__coderef_default_variable_DEFAULT__
                          ->( $_[0] );
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
                              && ( length($default_value) > 0 )
                          )
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "coderef_default_variable",
                            "NonEmptyStr"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for coerce
    # has declaration, file lib/Mite/Attribute.pm, line 97
    sub coerce {
        @_ > 1
          ? do {
            (
                !ref $_[1]
                  and (!defined $_[1]
                    or $_[1] eq q()
                    or $_[1] eq '0'
                    or $_[1] eq '1' )
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"coerce"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"coerce"} );
    }

    # Accessors for compiling_class
    # has declaration, file lib/Mite/Attribute.pm, line 30
    sub compiling_class {
        @_ > 1
          ? do {
            blessed( $_[1] ) && $_[1]->isa("Mite::Role")
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Role" );
            $_[0]{"compiling_class"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"compiling_class"} );
    }

    sub locally_set_compiling_class {
        defined wantarray
          or croak("This method cannot be called in void context");
        my $get   = "compiling_class";
        my $set   = "compiling_class";
        my $has   = sub { exists $_[0]{"compiling_class"} };
        my $clear = sub { delete $_[0]{"compiling_class"}; $_[0]; };
        my $old   = undef;
        my ( $self, $new ) = @_;
        my $restorer = $self->$has
          ? do {
            $old = $self->$get;
            sub { $self->$set($old) }
          }
          : sub { $self->$clear };
        @_ == 2 ? $self->$set($new) : $self->$clear;
        &guard( $restorer, $old );
    }

    # Accessors for default
    # has declaration, file lib/Mite/Attribute.pm, line 102
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_default" => "default" },
        );
    }
    else {
        *has_default = sub {
            @_ == 1
              or croak('Predicate "has_default" usage: $self->has_default()');
            exists $_[0]{"default"};
        };
    }

    sub default {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    ( !defined( $_[1] ) ) or do {

                        package Mite::Shim;
                        defined( $_[1] ) and do {
                            ref( \$_[1] ) eq 'SCALAR'
                              or ref( \( my $val = $_[1] ) ) eq 'SCALAR';
                        }
                      }
                      or ( ref( $_[1] ) eq 'CODE' )
                      or ( ref( $_[1] ) eq 'SCALAR' or ref( $_[1] ) eq 'REF' )
                      or do {

                        package Mite::Shim;
                        ( ref( $_[1] ) eq 'HASH' )
                          and not( grep !/\A(?:)\z/, keys %{ $_[1] } );
                      }
                      or do {

                        package Mite::Shim;
                        ( ref( $_[1] ) eq 'ARRAY' ) and @{ $_[1] } == 0;
                    }
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Undef|Str|CodeRef|ScalarRef|Dict[]|Tuple[]" );
            $_[0]{"default"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"default"} );
    }

    # Accessors for default_does_trigger
    # has declaration, file lib/Mite/Attribute.pm, line 108
    sub default_does_trigger {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    (
                        !ref $to_coerce
                          and (!defined $to_coerce
                            or $to_coerce eq q()
                            or $to_coerce eq '0'
                            or $to_coerce eq '1' )
                    )
                  ) ? $to_coerce
                  : ( ( !!1 ) ) ? scalar( do { local $_ = $to_coerce; !!$_ } )
                  :               $to_coerce;
            };
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"default_does_trigger"} = $value;
            $_[0];
          }
          : ( $_[0]{"default_does_trigger"} );
    }

    # Accessors for default_is_trusted
    # has declaration, file lib/Mite/Attribute.pm, line 108
    sub default_is_trusted {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    (
                        !ref $to_coerce
                          and (!defined $to_coerce
                            or $to_coerce eq q()
                            or $to_coerce eq '0'
                            or $to_coerce eq '1' )
                    )
                  ) ? $to_coerce
                  : ( ( !!1 ) ) ? scalar( do { local $_ = $to_coerce; !!$_ } )
                  :               $to_coerce;
            };
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"default_is_trusted"} = $value;
            $_[0];
          }
          : ( $_[0]{"default_is_trusted"} );
    }

    # Accessors for definition_context
    # has declaration, file lib/Mite/Attribute.pm, line 20
    sub definition_context {
        @_ > 1
          ? do {
            ( ref( $_[1] ) eq 'HASH' )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "HashRef" );
            $_[0]{"definition_context"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"definition_context"} );
    }

    # Accessors for documentation
    # has declaration, file lib/Mite/Attribute.pm, line 145
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "accessors"         => { "documentation"     => "documentation" },
            "exists_predicates" => { "has_documentation" => "documentation" },
        );
    }
    else {
        *documentation = sub {
            @_ > 1
              ? do { $_[0]{"documentation"} = $_[1]; $_[0]; }
              : ( $_[0]{"documentation"} );
        };
        *has_documentation = sub {
            @_ == 1
              or croak(
'Predicate "has_documentation" usage: $self->has_documentation()'
              );
            exists $_[0]{"documentation"};
        };
    }

    # Accessors for does
    # has declaration, file lib/Mite/Attribute.pm, line 82
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "_does" => "does" },
        );
    }
    else {
        *_does = sub {
            @_ == 1 or croak('Reader "_does" usage: $self->_does()');
            $_[0]{"does"};
        };
    }

    # Accessors for enum
    # has declaration, file lib/Mite/Attribute.pm, line 87
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_enum" => "enum" },
        );
    }
    else {
        *has_enum = sub {
            @_ == 1 or croak('Predicate "has_enum" usage: $self->has_enum()');
            exists $_[0]{"enum"};
        };
    }

    sub enum {
        @_ > 1
          ? do {
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
                            && ( length($i) > 0 )
                          );
                    };
                    $ok;
                }
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "ArrayRef[NonEmptyStr]" );
            $_[0]{"enum"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"enum"} );
    }

    # Accessors for handles
    # has declaration, file lib/Mite/Attribute.pm, line 149
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_handles" => "handles" },
        );
    }
    else {
        *has_handles = sub {
            @_ == 1
              or croak('Predicate "has_handles" usage: $self->has_handles()');
            exists $_[0]{"handles"};
        };
    }

    sub handles {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    do {

                        package Mite::Shim;
                        (
                            do {

                                package Mite::Shim;
                                ( ref($to_coerce) eq 'HASH' ) and do {
                                    my $ok = 1;
                                    for my $v ( values %{$to_coerce} ) {
                                        ( $ok = 0, last )
                                          unless (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($v) and do {
                                                        ref( \$v ) eq 'SCALAR'
                                                          or ref(
                                                            \( my $val = $v ) )
                                                          eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $v;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                            )
                                          );
                                    };
                                    for my $k ( keys %{$to_coerce} ) {
                                        ( $ok = 0, last ) unless do {

                                            package Mite::Shim;
                                            (
                                                (
                                                    (
                                                        do {

                                                            package Mite::Shim;
                                                            defined($k) and do {
                                                                ref( \$k ) eq
                                                                  'SCALAR'
                                                                  or ref(
                                                                    \(
                                                                        my $val
                                                                          = $k
                                                                    )
                                                                  ) eq 'SCALAR';
                                                            }
                                                        }
                                                    )
                                                      && (
                                                        do {
                                                            local $_ = $k;
                                                            /\A[^\W0-9]\w*\z/;
                                                        }
                                                      )
                                                )
                                                  or (
                                                    (
                                                        do {

                                                            package Mite::Shim;
                                                            defined($k) and do {
                                                                ref( \$k ) eq
                                                                  'SCALAR'
                                                                  or ref(
                                                                    \(
                                                                        my $val
                                                                          = $k
                                                                    )
                                                                  ) eq 'SCALAR';
                                                            }
                                                        }
                                                    )
                                                    && (
                                                        do {
                                                            local $_ = $k;
                                                            /\%/;
                                                        }
                                                    )
                                                  )
                                            );
                                        }
                                    };
                                    $ok;
                                }
                              }
                              or do {

                                package Mite::Shim;
                                (         defined($to_coerce)
                                      and !ref($to_coerce)
                                      and $to_coerce =~ m{\A(?:[12])\z} );
                            }
                        );
                    }
                ) ? $to_coerce : ( ( ref($to_coerce) eq 'ARRAY' ) ) ? scalar(
                    do {
                        local $_ = $to_coerce;
                        +{ map { $_ => $_ } @$_ };
                    }
                  )
                  : $to_coerce;
            };
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        ( ref($value) eq 'HASH' ) and do {
                            my $ok = 1;
                            for my $v ( values %{$value} ) {
                                ( $ok = 0, last )
                                  unless (
                                    (
                                        do {

                                            package Mite::Shim;
                                            defined($v) and do {
                                                ref( \$v ) eq 'SCALAR'
                                                  or ref( \( my $val = $v ) )
                                                  eq 'SCALAR';
                                            }
                                        }
                                    )
                                    && ( do { local $_ = $v; /\A[^\W0-9]\w*\z/ }
                                    )
                                  );
                            };
                            for my $k ( keys %{$value} ) {
                                ( $ok = 0, last ) unless do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($k) and do {
                                                        ref( \$k ) eq 'SCALAR'
                                                          or ref(
                                                            \( my $val = $k ) )
                                                          eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $k;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($k) and do {
                                                        ref( \$k ) eq 'SCALAR'
                                                          or ref(
                                                            \( my $val = $k ) )
                                                          eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && ( do { local $_ = $k; /\%/ } )
                                          )
                                    );
                                }
                            };
                            $ok;
                        }
                      }
                      or do {

                        package Mite::Shim;
                        (         defined($value)
                              and !ref($value)
                              and $value =~ m{\A(?:[12])\z} );
                    }
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "HandlesHash|Enum[\"1\",\"2\"]" );
            $_[0]{"handles"} = $value;
            $_[0];
          }
          : ( $_[0]{"handles"} );
    }

    # Accessors for handles_via
    # has declaration, file lib/Mite/Attribute.pm, line 155
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_handles_via" => "handles_via" },
        );
    }
    else {
        *has_handles_via = sub {
            @_ == 1
              or croak(
                'Predicate "has_handles_via" usage: $self->has_handles_via()');
            exists $_[0]{"handles_via"};
        };
    }

    sub handles_via {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    do {

                        package Mite::Shim;
                        ( ref($to_coerce) eq 'ARRAY' ) and do {
                            my $ok = 1;
                            for my $i ( @{$to_coerce} ) {
                                ( $ok = 0, last ) unless do {

                                    package Mite::Shim;
                                    defined($i) and do {
                                        ref( \$i ) eq 'SCALAR'
                                          or ref( \( my $val = $i ) ) eq
                                          'SCALAR';
                                    }
                                }
                            };
                            $ok;
                        }
                    }
                ) ? $to_coerce : (
                    do {

                        package Mite::Shim;
                        defined($to_coerce) and do {
                            ref( \$to_coerce ) eq 'SCALAR'
                              or ref( \( my $val = $to_coerce ) ) eq 'SCALAR';
                        }
                    }
                ) ? scalar( do { local $_ = $to_coerce; [$_] } ) : $to_coerce;
            };
            do {

                package Mite::Shim;
                ( ref($value) eq 'ARRAY' ) and do {
                    my $ok = 1;
                    for my $i ( @{$value} ) {
                        ( $ok = 0, last ) unless do {

                            package Mite::Shim;
                            defined($i) and do {
                                ref( \$i ) eq 'SCALAR'
                                  or ref( \( my $val = $i ) ) eq 'SCALAR';
                            }
                        }
                    };
                    $ok;
                }
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "ArrayRef[Str]" );
            $_[0]{"handles_via"} = $value;
            $_[0];
          }
          : ( $_[0]{"handles_via"} );
    }

    # Accessors for init_arg
    # has declaration, file lib/Mite/Attribute.pm, line 52
    sub init_arg {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
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
                          && ( length( $_[1] ) > 0 )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "NonEmptyStr|Undef" );
            $_[0]{"init_arg"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"init_arg"} ) ? $_[0]{"init_arg"} : (
                    $_[0]{"init_arg"} = do {
                        my $default_value =
                          $Mite::Attribute::__init_arg_DEFAULT__->(
                            $_[0] );
                        do {

                            package Mite::Shim;
                            (
                                (
                                    (
                                        do {

                                            package Mite::Shim;
                                            defined($default_value) and do {
                                                ref( \$default_value ) eq
                                                  'SCALAR'
                                                  or ref(
                                                    \(
                                                        my $val =
                                                          $default_value
                                                    )
                                                  ) eq 'SCALAR';
                                            }
                                        }
                                    )
                                      && ( length($default_value) > 0 )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "init_arg", "NonEmptyStr|Undef" );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for is
    # has declaration, file lib/Mite/Attribute.pm, line 66
    sub is {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (         defined( $_[1] )
                      and !ref( $_[1] )
                      and $_[1] =~ m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z} );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Enum[\"ro\",\"rw\",\"rwp\",\"lazy\",\"bare\"]" );
            $_[0]{"is"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"is"} );
    }

    # Accessors for isa
    # has declaration, file lib/Mite/Attribute.pm, line 77
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "_isa" => "isa" },
        );
    }
    else {
        *_isa = sub {
            @_ == 1 or croak('Reader "_isa" usage: $self->_isa()');
            $_[0]{"isa"};
        };
    }

    # Accessors for lazy
    # has declaration, file lib/Mite/Attribute.pm, line 115
    sub lazy {
        @_ > 1
          ? do {
            (
                !ref $_[1]
                  and (!defined $_[1]
                    or $_[1] eq q()
                    or $_[1] eq '0'
                    or $_[1] eq '1' )
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"lazy"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"lazy"} );
    }

    # Accessors for local_writer
    # has declaration, file lib/Mite/Attribute.pm, line 71
    sub local_writer {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|Undef" );
            $_[0]{"local_writer"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"local_writer"} ) ? $_[0]{"local_writer"} : (
                    $_[0]{"local_writer"} = do {
                        my $default_value = $_[0]->_build_local_writer;
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\%/;
                                                }
                                            )
                                          )
                                    );
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($default_value)
                                          and !ref($default_value)
                                          and $default_value =~ m{\A(?:1)\z} );
                                  }
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "local_writer",
                            "MethodNameTemplate|One|Undef"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for lvalue
    # has declaration, file lib/Mite/Attribute.pm, line 71
    sub lvalue {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|Undef" );
            $_[0]{"lvalue"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"lvalue"} ) ? $_[0]{"lvalue"} : (
                    $_[0]{"lvalue"} = do {
                        my $default_value = $_[0]->_build_lvalue;
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\%/;
                                                }
                                            )
                                          )
                                    );
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($default_value)
                                          and !ref($default_value)
                                          and $default_value =~ m{\A(?:1)\z} );
                                  }
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "lvalue",
                            "MethodNameTemplate|One|Undef"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for name
    # has declaration, file lib/Mite/Attribute.pm, line 43
    sub name {
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
                  && ( length( $_[1] ) > 0 )
              )
              or croak(
                "Type check failed in %s: value should be %s",
                "accessor",
                "NonEmptyStr"
              );
            $_[0]{"name"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"name"} );
    }

    # Accessors for predicate
    # has declaration, file lib/Mite/Attribute.pm, line 71
    sub predicate {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|Undef" );
            $_[0]{"predicate"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"predicate"} ) ? $_[0]{"predicate"} : (
                    $_[0]{"predicate"} = do {
                        my $default_value = $_[0]->_build_predicate;
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\%/;
                                                }
                                            )
                                          )
                                    );
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($default_value)
                                          and !ref($default_value)
                                          and $default_value =~ m{\A(?:1)\z} );
                                  }
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "predicate",
                            "MethodNameTemplate|One|Undef"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for reader
    # has declaration, file lib/Mite/Attribute.pm, line 71
    sub reader {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|Undef" );
            $_[0]{"reader"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"reader"} ) ? $_[0]{"reader"} : (
                    $_[0]{"reader"} = do {
                        my $default_value = $_[0]->_build_reader;
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\%/;
                                                }
                                            )
                                          )
                                    );
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($default_value)
                                          and !ref($default_value)
                                          and $default_value =~ m{\A(?:1)\z} );
                                  }
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "reader",
                            "MethodNameTemplate|One|Undef"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for required
    # has declaration, file lib/Mite/Attribute.pm, line 54
    sub required {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    (
                        !ref $to_coerce
                          and (!defined $to_coerce
                            or $to_coerce eq q()
                            or $to_coerce eq '0'
                            or $to_coerce eq '1' )
                    )
                  ) ? $to_coerce
                  : ( ( !!1 ) ) ? scalar( do { local $_ = $to_coerce; !!$_ } )
                  :               $to_coerce;
            };
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"required"} = $value;
            $_[0];
          }
          : ( $_[0]{"required"} );
    }

    # Accessors for skip_argc_check
    # has declaration, file lib/Mite/Attribute.pm, line 108
    sub skip_argc_check {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    (
                        !ref $to_coerce
                          and (!defined $to_coerce
                            or $to_coerce eq q()
                            or $to_coerce eq '0'
                            or $to_coerce eq '1' )
                    )
                  ) ? $to_coerce
                  : ( ( !!1 ) ) ? scalar( do { local $_ = $to_coerce; !!$_ } )
                  :               $to_coerce;
            };
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"skip_argc_check"} = $value;
            $_[0];
          }
          : ( $_[0]{"skip_argc_check"} );
    }

    # Accessors for trigger
    # has declaration, file lib/Mite/Attribute.pm, line 129
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_trigger" => "trigger" },
        );
    }
    else {
        *has_trigger = sub {
            @_ == 1
              or croak('Predicate "has_trigger" usage: $self->has_trigger()');
            exists $_[0]{"trigger"};
        };
    }

    sub trigger {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( ref( $_[1] ) eq 'CODE' )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|CodeRef" );
            $_[0]{"trigger"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"trigger"} );
    }

    # Accessors for type
    # has declaration, file lib/Mite/Attribute.pm, line 92
    sub type {
        @_ == 1 or croak('Reader "type" usage: $self->type()');
        (
            exists( $_[0]{"type"} ) ? $_[0]{"type"} : (
                $_[0]{"type"} = do {
                    my $default_value = $_[0]->_build_type;
                    do {

                        package Mite::Shim;
                        (
                            (
                                do {

                                    package Mite::Shim;
                                    use Scalar::Util ();
                                    Scalar::Util::blessed($default_value);
                                }
                            )
                              or ( !defined($default_value) )
                        );
                      }
                      or croak( "Type check failed in default: %s should be %s",
                        "type", "Object|Undef" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for weak_ref
    # has declaration, file lib/Mite/Attribute.pm, line 61
    sub weak_ref {
        @_ > 1
          ? do {
            (
                !ref $_[1]
                  and (!defined $_[1]
                    or $_[1] eq q()
                    or $_[1] eq '0'
                    or $_[1] eq '1' )
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"weak_ref"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"weak_ref"} );
    }

    # Accessors for writer
    # has declaration, file lib/Mite/Attribute.pm, line 71
    sub writer {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        (
                            (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                  && (
                                    do { local $_ = $_[1]; /\A[^\W0-9]\w*\z/ }
                                  )
                            )
                              or (
                                (
                                    do {

                                        package Mite::Shim;
                                        defined( $_[1] ) and do {
                                            ref( \$_[1] ) eq 'SCALAR'
                                              or ref( \( my $val = $_[1] ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && (
                                    do { local $_ = $_[1]; /\%/ }
                                )
                              )
                        );
                      }
                      or do {

                        package Mite::Shim;
                        (         defined( $_[1] )
                              and !ref( $_[1] )
                              and $_[1] =~ m{\A(?:1)\z} );
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "MethodNameTemplate|One|Undef" );
            $_[0]{"writer"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"writer"} ) ? $_[0]{"writer"} : (
                    $_[0]{"writer"} = do {
                        my $default_value = $_[0]->_build_writer;
                        do {

                            package Mite::Shim;
                            (
                                do {

                                    package Mite::Shim;
                                    (
                                        (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                              && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\A[^\W0-9]\w*\z/;
                                                }
                                              )
                                        )
                                          or (
                                            (
                                                do {

                                                    package Mite::Shim;
                                                    defined($default_value)
                                                      and do {
                                                        ref( \$default_value )
                                                          eq 'SCALAR'
                                                          or ref(
                                                            \(
                                                                my $val =
                                                                  $default_value
                                                            )
                                                          ) eq 'SCALAR';
                                                    }
                                                }
                                            )
                                            && (
                                                do {
                                                    local $_ = $default_value;
                                                    /\%/;
                                                }
                                            )
                                          )
                                    );
                                  }
                                  or do {

                                    package Mite::Shim;
                                    (         defined($default_value)
                                          and !ref($default_value)
                                          and $default_value =~ m{\A(?:1)\z} );
                                  }
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "writer",
                            "MethodNameTemplate|One|Undef"
                          );
                        $default_value;
                    }
                )
            )
        }
    }

    1;
}
