{

    package Mite::Compiled;
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

        # Attribute: file
        if ( exists $args->{"file"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"file"};
                    (
                        (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($to_coerce)
                                  and $to_coerce->isa(q[Path::Tiny]);
                            }
                        )
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
                      ? scalar(
                        do { local $_ = $to_coerce; Path::Tiny::path($_) }
                      )
                      : $to_coerce;
                };
                (
                    do {
                        use Scalar::Util ();
                        Scalar::Util::blessed($coerced_value)
                          and $coerced_value->isa(q[Path::Tiny]);
                    }
                  )
                  or croak "Type check failed in constructor: %s should be %s",
                  "file", "Path";
                $self->{"file"} = $coerced_value;
            };
        }

        # Attribute: source
        croak "Missing key in constructor: source"
          unless exists $args->{"source"};
        (
            do {
                use Scalar::Util ();
                Scalar::Util::blessed( $args->{"source"} )
                  and $args->{"source"}->isa(q[Mite::Source]);
            }
          )
          or croak "Type check failed in constructor: %s should be %s",
          "source", "InstanceOf[\"Mite::Source\"]";
        $self->{"source"} = $args->{"source"};

        # Enforce strict constructor
        my @unknown = grep not(/\A(?:file|source)\z/), keys %{$args};
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

    # Accessors for file
    sub file {
        @_ > 1
          ? do {
            my $value = do {
                my $to_coerce = $_[1];
                (
                    (
                        do {
                            use Scalar::Util ();
                            Scalar::Util::blessed($to_coerce)
                              and $to_coerce->isa(q[Path::Tiny]);
                        }
                    )
                ) ? $to_coerce : (
                    do {

                        package Mite::Shim;
                        defined($to_coerce) and do {
                            ref( \$to_coerce ) eq 'SCALAR'
                              or ref( \( my $val = $to_coerce ) ) eq 'SCALAR';
                        }
                    }
                  )
                  ? scalar(
                    do { local $_ = $to_coerce; Path::Tiny::path($_) }
                  )
                  : $to_coerce;
            };
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed($value)
                      and $value->isa(q[Path::Tiny]);
                }
              )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Path" );
            $_[0]{"file"} = $value;
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"file"} ) ? $_[0]{"file"} : (
                    $_[0]{"file"} = do {
                        my $default_value = do {
                            my $to_coerce = do {
                                my $method =
                                  $Mite::Compiled::__file_DEFAULT__;
                                $_[0]->$method;
                            };
                            (
                                (
                                    do {
                                        use Scalar::Util ();
                                        Scalar::Util::blessed($to_coerce)
                                          and $to_coerce->isa(q[Path::Tiny]);
                                    }
                                )
                            ) ? $to_coerce : (
                                do {

                                    package Mite::Shim;
                                    defined($to_coerce) and do {
                                        ref( \$to_coerce ) eq 'SCALAR'
                                          or ref( \( my $val = $to_coerce ) )
                                          eq 'SCALAR';
                                    }
                                }
                              )
                              ? scalar(
                                do {
                                    local $_ = $to_coerce;
                                    Path::Tiny::path($_);
                                }
                              )
                              : $to_coerce;
                        };
                        (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($default_value)
                                  and $default_value->isa(q[Path::Tiny]);
                            }
                          )
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "file", "Path" );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for source
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "source" => "source" },
        );
    }
    else {
        *source = sub {
            @_ > 1
              ? croak("source is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"source"};
        };
    }

    1;
}
