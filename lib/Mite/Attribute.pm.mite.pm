{

    package Mite::Attribute;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.007002";

    BEGIN {
        require Scalar::Util;
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

    sub new {
        my $class = ref( $_[0] ) ? ref(shift) : shift;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $self  = bless {}, $class;
        my $args =
            $meta->{HAS_BUILDARGS}
          ? $class->BUILDARGS(@_)
          : { ( @_ == 1 ) ? %{ $_[0] } : @_ };
        my $no_build = delete $args->{__no_BUILD__};

        # Attribute: _order
        $self->{"_order"} = $self->_build__order;

        # Attribute: class
        if ( exists $args->{"class"} ) {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"class"} )
                      and $args->{"class"}->isa(q[Mite::Role]);
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "class", "Mite::Role";
            $self->{"class"} = $args->{"class"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"class"} )
          if exists $self->{"class"};

        # Attribute: _class_for_default
        if ( exists $args->{"_class_for_default"} ) {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"_class_for_default"} )
                      and $args->{"_class_for_default"}->isa(q[Mite::Role]);
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "_class_for_default", "Mite::Role";
            $self->{"_class_for_default"} = $args->{"_class_for_default"};
        }
        require Scalar::Util
          && Scalar::Util::weaken( $self->{"_class_for_default"} )
          if exists $self->{"_class_for_default"};

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
            ) && do { package Mite::Shim; length( $args->{"name"} ) > 0 }
          )
          or croak "Type check failed in constructor: %s should be %s", "name",
          "NonEmptyStr";
        $self->{"name"} = $args->{"name"};

        # Attribute: init_arg
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

        # Attribute: required
        do {
            my $value =
              exists( $args->{"required"} ) ? $args->{"required"} : "";
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "required", "Bool";
            $self->{"required"} = $value;
        };

        # Attribute: weak_ref
        do {
            my $value =
              exists( $args->{"weak_ref"} ) ? $args->{"weak_ref"} : "";
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

        # Attribute: is
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

        # Attribute: reader
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

        # Attribute: writer
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

        # Attribute: accessor
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

        # Attribute: clearer
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

        # Attribute: predicate
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

        # Attribute: lvalue
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

        # Attribute: local_writer
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

        # Attribute: isa
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

        # Attribute: does
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

        # Attribute: type
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

        # Attribute: coerce
        do {
            my $value = exists( $args->{"coerce"} ) ? $args->{"coerce"} : "";
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

        # Attribute: default
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

        # Attribute: lazy
        do {
            my $value = exists( $args->{"lazy"} ) ? $args->{"lazy"} : "";
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

        # Attribute: coderef_default_variable
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

        # Attribute: trigger
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

        # Attribute: builder
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

        # Attribute: clone
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

        # Attribute: clone_on_read
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

        # Attribute: clone_on_write
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

        # Attribute: documentation
        if ( exists $args->{"documentation"} ) {
            $self->{"documentation"} = $args->{"documentation"};
        }

        # Attribute: handles
        if ( exists $args->{"handles"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"handles"};
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
                                              or ref( \( my $val = $v ) ) eq
                                              'SCALAR';
                                        }
                                    }
                                )
                                && ( do { local $_ = $v; /\A[^\W0-9]\w*\z/ } )
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
                                                    ref( \$k ) eq 'SCALAR'
                                                      or
                                                      ref( \( my $val = $k ) )
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
                                                      or
                                                      ref( \( my $val = $k ) )
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
                  or croak "Type check failed in constructor: %s should be %s",
                  "handles", "HandlesHash";
                $self->{"handles"} = $coerced_value;
            };
        }

        # Attribute: alias
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

        # Enforce strict constructor
        my @unknown = grep not(
/\A(?:_class_for_default|a(?:ccessor|lias)|builder|c(?:l(?:ass|earer|one(?:_on_(?:read|write))?)|o(?:deref_default_variable|erce))|d(?:efault|o(?:cumentation|es))|handles|i(?:nit_arg|sa?)|l(?:azy|ocal_writer|value)|name|predicate|re(?:ader|quired)|t(?:rigger|ype)|w(?:eak_ref|riter))\z/
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

    # Accessors for _class_for_default
    sub _class_for_default {
        @_ > 1
          ? do {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[1] )
                      and $_[1]->isa(q[Mite::Role]);
                }
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Role" );
            $_[0]{"_class_for_default"} = $_[1];
            require Scalar::Util
              && Scalar::Util::weaken( $_[0]{"_class_for_default"} );
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"_class_for_default"} )
                ? $_[0]{"_class_for_default"}
                : (
                    $_[0]{"_class_for_default"} = do {
                        my $default_value = $_[0]->_build__class_for_default;
                        (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($default_value)
                                  and $default_value->isa(q[Mite::Role]);
                            }
                          )
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
    sub alias_is_for {
        @_ > 1
          ? croak("alias_is_for is a read-only attribute of @{[ref $_[0]]}")
          : (
            exists( $_[0]{"alias_is_for"} ) ? $_[0]{"alias_is_for"}
            : ( $_[0]{"alias_is_for"} = $_[0]->_build_alias_is_for ) );
    }

    # Accessors for builder
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_builder" => "builder" },
        );
    }
    else {
        *has_builder = sub { exists $_[0]{"builder"} };
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
    sub class {
        @_ > 1
          ? do {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[1] )
                      and $_[1]->isa(q[Mite::Role]);
                }
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Role" );
            $_[0]{"class"} = $_[1];
            require Scalar::Util && Scalar::Util::weaken( $_[0]{"class"} );
            $_[0];
          }
          : ( $_[0]{"class"} );
    }

    # Accessors for clearer
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
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "cloner_method" => "clone" },
        );
    }
    else {
        *cloner_method = sub {
            @_ > 1
              ? croak("clone is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"clone"};
        };
    }

    # Accessors for clone_on_read
    sub clone_on_read {
        @_ > 1
          ? croak("clone_on_read is a read-only attribute of @{[ref $_[0]]}")
          : (
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
    sub clone_on_write {
        @_ > 1
          ? croak("clone_on_write is a read-only attribute of @{[ref $_[0]]}")
          : (
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
    sub compiling_class {
        @_ > 1
          ? do {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[1] )
                      and $_[1]->isa(q[Mite::Role]);
                }
              )
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
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_default" => "default" },
        );
    }
    else {
        *has_default = sub { exists $_[0]{"default"} };
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

    # Accessors for documentation
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
        *has_documentation = sub { exists $_[0]{"documentation"} };
    }

    # Accessors for does
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "_does" => "does" },
        );
    }
    else {
        *_does = sub {
            @_ > 1
              ? croak("does is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"does"};
        };
    }

    # Accessors for handles
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_handles" => "handles" },
        );
    }
    else {
        *has_handles = sub { exists $_[0]{"handles"} };
    }

    sub handles {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
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
                                                  or ref( \( my $val = $v ) )
                                                  eq 'SCALAR';
                                            }
                                        }
                                    )
                                    && ( do { local $_ = $v; /\A[^\W0-9]\w*\z/ }
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
                                          or ref( \( my $val = $v ) ) eq
                                          'SCALAR';
                                    }
                                }
                            )
                            && ( do { local $_ = $v; /\A[^\W0-9]\w*\z/ } )
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
                                                  or ref( \( my $val = $k ) )
                                                  eq 'SCALAR';
                                            }
                                        }
                                    )
                                      && (
                                        do { local $_ = $k; /\A[^\W0-9]\w*\z/ }
                                      )
                                )
                                  or (
                                    (
                                        do {

                                            package Mite::Shim;
                                            defined($k) and do {
                                                ref( \$k ) eq 'SCALAR'
                                                  or ref( \( my $val = $k ) )
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
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "HandlesHash" );
            $_[0]{"handles"} = $value;
            $_[0];
          }
          : ( $_[0]{"handles"} );
    }

    # Accessors for init_arg
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
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "_isa" => "isa" },
        );
    }
    else {
        *_isa = sub {
            @_ > 1
              ? croak("isa is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"isa"};
        };
    }

    # Accessors for lazy
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
    sub required {
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
            $_[0]{"required"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"required"} );
    }

    # Accessors for trigger
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "has_trigger" => "trigger" },
        );
    }
    else {
        *has_trigger = sub { exists $_[0]{"trigger"} };
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
    sub type {
        @_ > 1 ? croak("type is a read-only attribute of @{[ref $_[0]]}") : (
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
