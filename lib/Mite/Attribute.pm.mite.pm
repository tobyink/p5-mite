{

    package Mite::Attribute;
    our $USES_MITE = "Mite::Class";
    our $MITE_SHIM = "Mite::Shim";
    use strict;
    use warnings;

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

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"class"} );
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "class", "Object";
            $self->{"class"} = $args->{"class"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"class"} )
          if exists $self->{"class"};

        # Attribute: _class_for_default
        if ( exists $args->{"_class_for_default"} ) {
            (
                do {

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"_class_for_default"} );
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "_class_for_default", "Object";
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
            )
              && (
                do { local $_ = $args->{"name"}; length($_) > 0 }
              )
          )
          or croak "Type check failed in constructor: %s should be %s", "name",
          "__ANON__";
        $self->{"name"} = $args->{"name"};

        # Attribute: init_arg
        if ( exists $args->{"init_arg"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        defined( $args->{"init_arg"} ) and do {
                            ref( \$args->{"init_arg"} ) eq 'SCALAR'
                              or ref( \( my $val = $args->{"init_arg"} ) ) eq
                              'SCALAR';
                        }
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"init_arg"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "init_arg", "Str|Undef";
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
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"reader"} ) and do {
                                    ref( \$args->{"reader"} ) eq 'SCALAR'
                                      or ref( \( my $val = $args->{"reader"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do { local $_ = $args->{"reader"}; length($_) > 0 }
                          )
                    )
                      or
                      do { package Mite::Shim; !defined( $args->{"reader"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "reader", "__ANON__|Undef";
            $self->{"reader"} = $args->{"reader"};
        }

        # Attribute: writer
        if ( exists $args->{"writer"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"writer"} ) and do {
                                    ref( \$args->{"writer"} ) eq 'SCALAR'
                                      or ref( \( my $val = $args->{"writer"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do { local $_ = $args->{"writer"}; length($_) > 0 }
                          )
                    )
                      or
                      do { package Mite::Shim; !defined( $args->{"writer"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "writer", "__ANON__|Undef";
            $self->{"writer"} = $args->{"writer"};
        }

        # Attribute: accessor
        if ( exists $args->{"accessor"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"accessor"} ) and do {
                                    ref( \$args->{"accessor"} ) eq 'SCALAR'
                                      or
                                      ref( \( my $val = $args->{"accessor"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do {
                                local $_ = $args->{"accessor"};
                                length($_) > 0;
                            }
                          )
                    )
                      or
                      do { package Mite::Shim; !defined( $args->{"accessor"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "accessor", "__ANON__|Undef";
            $self->{"accessor"} = $args->{"accessor"};
        }

        # Attribute: clearer
        if ( exists $args->{"clearer"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"clearer"} ) and do {
                                    ref( \$args->{"clearer"} ) eq 'SCALAR'
                                      or
                                      ref( \( my $val = $args->{"clearer"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do { local $_ = $args->{"clearer"}; length($_) > 0 }
                          )
                    )
                      or
                      do { package Mite::Shim; !defined( $args->{"clearer"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "clearer", "__ANON__|Undef";
            $self->{"clearer"} = $args->{"clearer"};
        }

        # Attribute: predicate
        if ( exists $args->{"predicate"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"predicate"} ) and do {
                                    ref( \$args->{"predicate"} ) eq 'SCALAR'
                                      or
                                      ref( \( my $val = $args->{"predicate"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do {
                                local $_ = $args->{"predicate"};
                                length($_) > 0;
                            }
                          )
                    )
                      or do {

                        package Mite::Shim;
                        !defined( $args->{"predicate"} );
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "predicate", "__ANON__|Undef";
            $self->{"predicate"} = $args->{"predicate"};
        }

        # Attribute: lvalue
        if ( exists $args->{"lvalue"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"lvalue"} ) and do {
                                    ref( \$args->{"lvalue"} ) eq 'SCALAR'
                                      or ref( \( my $val = $args->{"lvalue"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do { local $_ = $args->{"lvalue"}; length($_) > 0 }
                          )
                    )
                      or
                      do { package Mite::Shim; !defined( $args->{"lvalue"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "lvalue", "__ANON__|Undef";
            $self->{"lvalue"} = $args->{"lvalue"};
        }

        # Attribute: local_writer
        if ( exists $args->{"local_writer"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"local_writer"} ) and do {
                                    ref( \$args->{"local_writer"} ) eq 'SCALAR'
                                      or ref(
                                        \( my $val = $args->{"local_writer"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do {
                                local $_ = $args->{"local_writer"};
                                length($_) > 0;
                            }
                          )
                    )
                      or do {

                        package Mite::Shim;
                        !defined( $args->{"local_writer"} );
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "local_writer", "__ANON__|Undef";
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
                      or (
                        do {

                            package Mite::Shim;
                            use Scalar::Util ();
                            Scalar::Util::blessed( $args->{"isa"} );
                        }
                      )
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "isa", "Str|Object";
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
                      or (
                        do {

                            package Mite::Shim;
                            use Scalar::Util ();
                            Scalar::Util::blessed( $args->{"does"} );
                        }
                      )
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "does", "Str|Object";
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
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "default", "Undef|Str|CodeRef|ScalarRef";
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
            do {

                package Mite::Shim;
                defined( $args->{"coderef_default_variable"} ) and do {
                    ref( \$args->{"coderef_default_variable"} ) eq 'SCALAR'
                      or
                      ref( \( my $val = $args->{"coderef_default_variable"} ) )
                      eq 'SCALAR';
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "coderef_default_variable", "Str";
            $self->{"coderef_default_variable"} =
              $args->{"coderef_default_variable"};
        }

        # Attribute: trigger
        if ( exists $args->{"trigger"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"trigger"} ) and do {
                                    ref( \$args->{"trigger"} ) eq 'SCALAR'
                                      or
                                      ref( \( my $val = $args->{"trigger"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do { local $_ = $args->{"trigger"}; length($_) > 0 }
                          )
                    )
                      or do {

                        package Mite::Shim;
                        ref( $args->{"trigger"} ) eq 'CODE';
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"trigger"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "trigger", "__ANON__|CodeRef|Undef";
            $self->{"trigger"} = $args->{"trigger"};
        }

        # Attribute: builder
        if ( exists $args->{"builder"} ) {
            do {

                package Mite::Shim;
                (
                    (
                        (
                            do {

                                package Mite::Shim;
                                defined( $args->{"builder"} ) and do {
                                    ref( \$args->{"builder"} ) eq 'SCALAR'
                                      or
                                      ref( \( my $val = $args->{"builder"} ) )
                                      eq 'SCALAR';
                                }
                            }
                        )
                          && (
                            do { local $_ = $args->{"builder"}; length($_) > 0 }
                          )
                    )
                      or do {

                        package Mite::Shim;
                        ref( $args->{"builder"} ) eq 'CODE';
                      }
                      or
                      do { package Mite::Shim; !defined( $args->{"builder"} ) }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "builder", "__ANON__|CodeRef|Undef";
            $self->{"builder"} = $args->{"builder"};
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
                                for my $i ( values %{$to_coerce} ) {
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
                        for my $i ( values %{$coerced_value} ) {
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
                  "handles", "HashRef[Str]";
                $self->{"handles"} = $coerced_value;
            };
        }

        # Attribute: alias
        do {
            my $value = exists( $args->{"alias"} ) ? $args->{"alias"} : do {
                my $method = $Mite::Attribute::__alias_DEFAULT__;
                $self->$method;
            };
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
                  "alias", "ArrayRef[Str]";
                $self->{"alias"} = $coerced_value;
            };
        };

        # Enforce strict constructor
        my @unknown = grep not(
/\A(?:_class_for_default|a(?:ccessor|lias)|builder|c(?:l(?:ass|earer)|o(?:deref_default_variable|erce))|d(?:efault|o(?:cumentation|es))|handles|i(?:nit_arg|sa?)|l(?:azy|ocal_writer|value)|name|predicate|re(?:ader|quired)|t(?:rigger|ype)|w(?:eak_ref|riter))\z/
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

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[1] );
                }
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Object" );
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

                                package Mite::Shim;
                                use Scalar::Util ();
                                Scalar::Util::blessed($default_value);
                            }
                          )
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "_class_for_default", "Object" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|Undef" );
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
                                      && (
                                        do {
                                            local $_ = $default_value;
                                            length($_) > 0;
                                        }
                                      )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "accessor", "__ANON__|Undef" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( ref( $_[1] ) eq 'CODE' )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|CodeRef|Undef" );
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

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[1] );
                }
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Object" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|Undef" );
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
                                      && (
                                        do {
                                            local $_ = $default_value;
                                            length($_) > 0;
                                        }
                                      )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "clearer", "__ANON__|Undef" );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for coderef_default_variable
    sub coderef_default_variable {
        @_ > 1
          ? do {
            do {

                package Mite::Shim;
                defined( $_[1] ) and do {
                    ref( \$_[1] ) eq 'SCALAR'
                      or ref( \( my $val = $_[1] ) ) eq 'SCALAR';
                }
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Str" );
            $_[0]{"coderef_default_variable"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"coderef_default_variable"} )
                ? $_[0]{"coderef_default_variable"}
                : (
                    $_[0]{"coderef_default_variable"} = do {
                        my $default_value = do {
                            my $method =
                              $Mite::Attribute::__coderef_default_variable_DEFAULT__;
                            $_[0]->$method;
                        };
                        do {

                            package Mite::Shim;
                            defined($default_value) and do {
                                ref( \$default_value ) eq 'SCALAR'
                                  or ref( \( my $val = $default_value ) ) eq
                                  'SCALAR';
                            }
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "coderef_default_variable", "Str" );
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

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[1] );
                }
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Object" );
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
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Undef|Str|CodeRef|ScalarRef" );
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
                            for my $i ( values %{$to_coerce} ) {
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
                    for my $i ( values %{$value} ) {
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
                "accessor", "HashRef[Str]" );
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
                    do {

                        package Mite::Shim;
                        defined( $_[1] ) and do {
                            ref( \$_[1] ) eq 'SCALAR'
                              or ref( \( my $val = $_[1] ) ) eq 'SCALAR';
                        }
                      }
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Str|Undef" );
            $_[0]{"init_arg"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"init_arg"} ) ? $_[0]{"init_arg"} : (
                    $_[0]{"init_arg"} = do {
                        my $default_value = do {
                            my $method =
                              $Mite::Attribute::__init_arg_DEFAULT__;
                            $_[0]->$method;
                        };
                        do {

                            package Mite::Shim;
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
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "init_arg", "Str|Undef" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|Undef" );
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
                                      && (
                                        do {
                                            local $_ = $default_value;
                                            length($_) > 0;
                                        }
                                      )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "local_writer", "__ANON__|Undef" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|Undef" );
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
                                      && (
                                        do {
                                            local $_ = $default_value;
                                            length($_) > 0;
                                        }
                                      )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "lvalue", "__ANON__|Undef" );
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
                  && (
                    do { local $_ = $_[1]; length($_) > 0 }
                  )
              )
              or croak(
                "Type check failed in %s: value should be %s",
                "accessor",
                "__ANON__"
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|Undef" );
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
                                      && (
                                        do {
                                            local $_ = $default_value;
                                            length($_) > 0;
                                        }
                                      )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "predicate", "__ANON__|Undef" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|Undef" );
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
                                      && (
                                        do {
                                            local $_ = $default_value;
                                            length($_) > 0;
                                        }
                                      )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "reader", "__ANON__|Undef" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( ref( $_[1] ) eq 'CODE' )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|CodeRef|Undef" );
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
                            do { local $_ = $_[1]; length($_) > 0 }
                          )
                    )
                      or ( !defined( $_[1] ) )
                );
              }
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|Undef" );
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
                                      && (
                                        do {
                                            local $_ = $default_value;
                                            length($_) > 0;
                                        }
                                      )
                                )
                                  or ( !defined($default_value) )
                            );
                          }
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "writer", "__ANON__|Undef" );
                        $default_value;
                    }
                )
            )
        }
    }

    1;
}
