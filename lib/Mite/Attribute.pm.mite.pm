{

    package Mite::Attribute;
    our $USES_MITE = "Mite::Class";
    our $MITE_SHIM = "Mite::Shim";
    use strict;
    use warnings;

    sub new {
        my $class = ref( $_[0] ) ? ref(shift) : shift;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $self  = bless {}, $class;
        my $args =
            $meta->{HAS_BUILDARGS}
          ? $class->BUILDARGS(@_)
          : { ( @_ == 1 ) ? %{ $_[0] } : @_ };
        my $no_build = delete $args->{__no_BUILD__};

        # Initialize attributes
        do { my $value = $self->_build__order; $self->{"_order"} = $value; };
        if ( exists $args->{"class"} ) {
            (
                do {

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"class"} );
                }
              )
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "class", "Object" );
            $self->{"class"} = $args->{"class"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"class"} );
        if ( exists $args->{"_class_for_default"} ) {
            (
                do {

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"_class_for_default"} );
                }
              )
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "_class_for_default", "Object" );
            $self->{"_class_for_default"} = $args->{"_class_for_default"};
        }
        require Scalar::Util
          && Scalar::Util::weaken( $self->{"_class_for_default"} );
        if ( exists $args->{"name"} ) {
            (
                (
                    do {

                        package Mite::Shim;
                        defined( $args->{"name"} ) and do {
                            ref( \$args->{"name"} ) eq 'SCALAR'
                              or ref( \( my $val = $args->{"name"} ) ) eq
                              'SCALAR';
                        }
                    }
                )
                  && (
                    do { local $_ = $args->{"name"}; length($_) > 0 }
                  )
              )
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "name",
                "__ANON__"
              );
            $self->{"name"} = $args->{"name"};
        }
        else { Mite::Shim::croak("Missing key in constructor: name") }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "init_arg", "Str|Undef" );
            $self->{"init_arg"} = $args->{"init_arg"};
        }
        if ( exists $args->{"required"} ) {
            do {

                package Mite::Shim;
                !ref $args->{"required"}
                  and (!defined $args->{"required"}
                    or $args->{"required"} eq q()
                    or $args->{"required"} eq '0'
                    or $args->{"required"} eq '1' );
              }
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "required", "Bool" );
            $self->{"required"} = $args->{"required"};
        }
        else {
            my $value = do {
                my $default_value = "";
                (
                    !ref $default_value
                      and (!defined $default_value
                        or $default_value eq q()
                        or $default_value eq '0'
                        or $default_value eq '1' )
                  )
                  or Mite::Shim::croak(
                    "Type check failed in default: %s should be %s",
                    "required", "Bool" );
                $default_value;
            };
            $self->{"required"} = $value;
        }
        if ( exists $args->{"weak_ref"} ) {
            do {

                package Mite::Shim;
                !ref $args->{"weak_ref"}
                  and (!defined $args->{"weak_ref"}
                    or $args->{"weak_ref"} eq q()
                    or $args->{"weak_ref"} eq '0'
                    or $args->{"weak_ref"} eq '1' );
              }
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "weak_ref", "Bool" );
            $self->{"weak_ref"} = $args->{"weak_ref"};
        }
        else {
            my $value = do {
                my $default_value = "";
                (
                    !ref $default_value
                      and (!defined $default_value
                        or $default_value eq q()
                        or $default_value eq '0'
                        or $default_value eq '1' )
                  )
                  or Mite::Shim::croak(
                    "Type check failed in default: %s should be %s",
                    "weak_ref", "Bool" );
                $default_value;
            };
            $self->{"weak_ref"} = $value;
        }
        if ( exists $args->{"is"} ) {
            do {

                package Mite::Shim;
                (         defined( $args->{"is"} )
                      and !ref( $args->{"is"} )
                      and $args->{"is"} =~ m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z} );
              }
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "is", "Enum[\"ro\",\"rw\",\"rwp\",\"lazy\",\"bare\"]" );
            $self->{"is"} = $args->{"is"};
        }
        else {
            my $value = do {
                my $default_value = "bare";
                do {

                    package Mite::Shim;
                    (         defined($default_value)
                          and !ref($default_value)
                          and $default_value =~
                          m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z} );
                  }
                  or Mite::Shim::croak(
                    "Type check failed in default: %s should be %s",
                    "is", "Enum[\"ro\",\"rw\",\"rwp\",\"lazy\",\"bare\"]" );
                $default_value;
            };
            $self->{"is"} = $value;
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "reader", "__ANON__|Undef" );
            $self->{"reader"} = $args->{"reader"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "writer", "__ANON__|Undef" );
            $self->{"writer"} = $args->{"writer"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "accessor", "__ANON__|Undef" );
            $self->{"accessor"} = $args->{"accessor"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "clearer", "__ANON__|Undef" );
            $self->{"clearer"} = $args->{"clearer"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "predicate", "__ANON__|Undef" );
            $self->{"predicate"} = $args->{"predicate"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "isa", "Str|Object" );
            $self->{"isa"} = $args->{"isa"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "does", "Str|Object" );
            $self->{"does"} = $args->{"does"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "type", "Object|Undef" );
            $self->{"type"} = $args->{"type"};
        }
        if ( exists $args->{"coerce"} ) {
            do {

                package Mite::Shim;
                !ref $args->{"coerce"}
                  and (!defined $args->{"coerce"}
                    or $args->{"coerce"} eq q()
                    or $args->{"coerce"} eq '0'
                    or $args->{"coerce"} eq '1' );
              }
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "coerce", "Bool" );
            $self->{"coerce"} = $args->{"coerce"};
        }
        else {
            my $value = do {
                my $default_value = "";
                (
                    !ref $default_value
                      and (!defined $default_value
                        or $default_value eq q()
                        or $default_value eq '0'
                        or $default_value eq '1' )
                  )
                  or Mite::Shim::croak(
                    "Type check failed in default: %s should be %s",
                    "coerce", "Bool" );
                $default_value;
            };
            $self->{"coerce"} = $value;
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "default",
                "Undef|Str|CodeRef|ScalarRef"
              );
            $self->{"default"} = $args->{"default"};
        }
        if ( exists $args->{"lazy"} ) {
            do {

                package Mite::Shim;
                !ref $args->{"lazy"}
                  and (!defined $args->{"lazy"}
                    or $args->{"lazy"} eq q()
                    or $args->{"lazy"} eq '0'
                    or $args->{"lazy"} eq '1' );
              }
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "lazy", "Bool" );
            $self->{"lazy"} = $args->{"lazy"};
        }
        else {
            my $value = do {
                my $default_value = "";
                (
                    !ref $default_value
                      and (!defined $default_value
                        or $default_value eq q()
                        or $default_value eq '0'
                        or $default_value eq '1' )
                  )
                  or Mite::Shim::croak(
                    "Type check failed in default: %s should be %s",
                    "lazy", "Bool" );
                $default_value;
            };
            $self->{"lazy"} = $value;
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "coderef_default_variable", "Str" );
            $self->{"coderef_default_variable"} =
              $args->{"coderef_default_variable"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "trigger", "__ANON__|CodeRef|Undef" );
            $self->{"trigger"} = $args->{"trigger"};
        }
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "builder", "__ANON__|CodeRef|Undef" );
            $self->{"builder"} = $args->{"builder"};
        }
        if ( exists $args->{"documentation"} ) {
            $self->{"documentation"} = $args->{"documentation"};
        }
        if ( exists $args->{"handles"} ) {
            my $value = do {
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "handles", "HashRef[Str]" );
            $self->{"handles"} = $value;
        }
        if ( exists $args->{"alias"} ) {
            my $value = do {
                my $to_coerce = $args->{"alias"};
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
              or Mite::Shim::croak(
                "Type check failed in constructor: %s should be %s",
                "alias", "ArrayRef[Str]" );
            $self->{"alias"} = $value;
        }
        else {
            my $value = do {
                my $default_value = do {
                    my $to_coerce = do {
                        my $method =
                          $Mite::Attribute::__alias_DEFAULT__;
                        $self->$method;
                    };
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
                    ( ref($default_value) eq 'ARRAY' ) and do {
                        my $ok = 1;
                        for my $i ( @{$default_value} ) {
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
                  or Mite::Shim::croak(
                    "Type check failed in default: %s should be %s",
                    "alias", "ArrayRef[Str]" );
                $default_value;
            };
            $self->{"alias"} = $value;
        }

        # Enforce strict constructor
        my @unknown = grep not(
/\A(?:_class_for_default|a(?:ccessor|lias)|builder|c(?:l(?:ass|earer)|o(?:deref_default_variable|erce))|d(?:efault|o(?:cumentation|es))|handles|i(?:nit_arg|sa?)|lazy|name|predicate|re(?:ader|quired)|t(?:rigger|ype)|w(?:eak_ref|riter))\z/
        ), keys %{$args};
        @unknown
          and Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
                "accessor", "ArrayRef[Str]" );
            $_[0]{"alias"} = $value;
            $_[0];
          }
          : ( $_[0]{"alias"} );
    }

    # Accessors for alias_is_for
    sub alias_is_for {
        @_ > 1
          ? Mite::Shim::croak(
            "alias_is_for is a read-only attribute of @{[ref $_[0]]}")
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"coerce"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"coerce"} );
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
              ? Mite::Shim::croak(
                "does is a read-only attribute of @{[ref $_[0]]}")
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
              ? Mite::Shim::croak(
                "isa is a read-only attribute of @{[ref $_[0]]}")
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
                "accessor", "Bool" );
            $_[0]{"lazy"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"lazy"} );
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
              or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
                "accessor", "__ANON__|CodeRef|Undef" );
            $_[0]{"trigger"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"trigger"} );
    }

    # Accessors for type
    sub type {
        @_ > 1
          ? Mite::Shim::croak("type is a read-only attribute of @{[ref $_[0]]}")
          : (
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
                      or Mite::Shim::croak(
                        "Type check failed in default: %s should be %s",
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
              or
              Mite::Shim::croak( "Type check failed in %s: value should be %s",
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
                          or Mite::Shim::croak(
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
