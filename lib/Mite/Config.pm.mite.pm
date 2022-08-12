{

    package Mite::Config;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.010003";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) = ( "Mite::Shim", "Mite::Config" );
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

        # Attribute mite_dir_name (type: Str)
        # has declaration, file lib/Mite/Config.pm, line 11
        do {
            my $value =
              exists( $args->{"mite_dir_name"} )
              ? $args->{"mite_dir_name"}
              : ".mite";
            do {

                package Mite::Shim;
                defined($value) and do {
                    ref( \$value ) eq 'SCALAR'
                      or ref( \( my $val = $value ) ) eq 'SCALAR';
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "mite_dir_name", "Str";
            $self->{"mite_dir_name"} = $value;
        };

        # Attribute mite_dir (type: Path)
        # has declaration, file lib/Mite/Config.pm, line 25
        if ( exists $args->{"mite_dir"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"mite_dir"};
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
                      : (
                        do {

                            package Mite::Shim;
                            defined($to_coerce) && !ref($to_coerce)
                              or Scalar::Util::blessed($to_coerce) && (
                                sub {
                                    require overload;
                                    overload::Overloaded( ref $_[0] or $_[0] )
                                      and
                                      overload::Method( ( ref $_[0] or $_[0] ),
                                        $_[1] );
                                }
                            )->( $to_coerce, q[""] );
                        }
                      )
                      ? scalar(
                        do { local $_ = $to_coerce; Path::Tiny::path($_) }
                      )
                      : ( ( ref($to_coerce) eq 'ARRAY' ) ) ? scalar(
                        do { local $_ = $to_coerce; Path::Tiny::path(@$_) }
                      )
                      : $to_coerce;
                };
                blessed($coerced_value) && $coerced_value->isa("Path::Tiny")
                  or croak "Type check failed in constructor: %s should be %s",
                  "mite_dir", "Path";
                $self->{"mite_dir"} = $coerced_value;
            };
        }

        # Attribute config_file (type: Path)
        # has declaration, file lib/Mite/Config.pm, line 35
        if ( exists $args->{"config_file"} ) {
            do {
                my $coerced_value = do {
                    my $to_coerce = $args->{"config_file"};
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
                      : (
                        do {

                            package Mite::Shim;
                            defined($to_coerce) && !ref($to_coerce)
                              or Scalar::Util::blessed($to_coerce) && (
                                sub {
                                    require overload;
                                    overload::Overloaded( ref $_[0] or $_[0] )
                                      and
                                      overload::Method( ( ref $_[0] or $_[0] ),
                                        $_[1] );
                                }
                            )->( $to_coerce, q[""] );
                        }
                      )
                      ? scalar(
                        do { local $_ = $to_coerce; Path::Tiny::path($_) }
                      )
                      : ( ( ref($to_coerce) eq 'ARRAY' ) ) ? scalar(
                        do { local $_ = $to_coerce; Path::Tiny::path(@$_) }
                      )
                      : $to_coerce;
                };
                blessed($coerced_value) && $coerced_value->isa("Path::Tiny")
                  or croak "Type check failed in constructor: %s should be %s",
                  "config_file", "Path";
                $self->{"config_file"} = $coerced_value;
            };
        }

        # Attribute data (type: HashRef)
        # has declaration, file lib/Mite/Config.pm, line 44
        if ( exists $args->{"data"} ) {
            do { package Mite::Shim; ref( $args->{"data"} ) eq 'HASH' }
              or croak "Type check failed in constructor: %s should be %s",
              "data", "HashRef";
            $self->{"data"} = $args->{"data"};
        }

        # Attribute search_for_mite_dir (type: Bool)
        # has declaration, file lib/Mite/Config.pm, line 46
        do {
            my $value =
              exists( $args->{"search_for_mite_dir"} )
              ? $args->{"search_for_mite_dir"}
              : true;
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "search_for_mite_dir", "Bool";
            $self->{"search_for_mite_dir"} = $value;
        };

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(
            /\A(?:config_file|data|mite_dir(?:_name)?|search_for_mite_dir)\z/),
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

    # Accessors for config_file
    # has declaration, file lib/Mite/Config.pm, line 35
    sub config_file {
        @_ == 1 or croak('Reader "config_file" usage: $self->config_file()');
        (
            exists( $_[0]{"config_file"} ) ? $_[0]{"config_file"} : (
                $_[0]{"config_file"} = do {
                    my $default_value = do {
                        my $to_coerce =
                          $Mite::Config::__config_file_DEFAULT__->(
                            $_[0] );
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
                          : (
                            do {

                                package Mite::Shim;
                                defined($to_coerce) && !ref($to_coerce)
                                  or Scalar::Util::blessed($to_coerce) && (
                                    sub {
                                        require overload;
                                        overload::Overloaded(
                                            ref $_[0]
                                              or $_[0]
                                          )
                                          and overload::Method(
                                            ( ref $_[0] or $_[0] ), $_[1] );
                                    }
                                )->( $to_coerce, q[""] );
                            }
                          )
                          ? scalar(
                            do { local $_ = $to_coerce; Path::Tiny::path($_) }
                          )
                          : ( ( ref($to_coerce) eq 'ARRAY' ) ) ? scalar(
                            do { local $_ = $to_coerce; Path::Tiny::path(@$_) }
                          )
                          : $to_coerce;
                    };
                    blessed($default_value) && $default_value->isa("Path::Tiny")
                      or croak( "Type check failed in default: %s should be %s",
                        "config_file", "Path" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for data
    # has declaration, file lib/Mite/Config.pm, line 44
    sub data {
        @_ > 1
          ? do {
            ( ref( $_[1] ) eq 'HASH' )
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "HashRef" );
            $_[0]{"data"} = $_[1];
            $_[0];
          }
          : do {
            (
                exists( $_[0]{"data"} ) ? $_[0]{"data"} : (
                    $_[0]{"data"} = do {
                        my $default_value =
                          $Mite::Config::__data_DEFAULT__->( $_[0] );
                        ( ref($default_value) eq 'HASH' )
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "data", "HashRef" );
                        $default_value;
                    }
                )
            )
        }
    }

    # Accessors for mite_dir
    # has declaration, file lib/Mite/Config.pm, line 25
    sub mite_dir {
        @_ == 1 or croak('Reader "mite_dir" usage: $self->mite_dir()');
        (
            exists( $_[0]{"mite_dir"} ) ? $_[0]{"mite_dir"} : (
                $_[0]{"mite_dir"} = do {
                    my $default_value = do {
                        my $to_coerce =
                          $Mite::Config::__mite_dir_DEFAULT__->(
                            $_[0] );
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
                          : (
                            do {

                                package Mite::Shim;
                                defined($to_coerce) && !ref($to_coerce)
                                  or Scalar::Util::blessed($to_coerce) && (
                                    sub {
                                        require overload;
                                        overload::Overloaded(
                                            ref $_[0]
                                              or $_[0]
                                          )
                                          and overload::Method(
                                            ( ref $_[0] or $_[0] ), $_[1] );
                                    }
                                )->( $to_coerce, q[""] );
                            }
                          )
                          ? scalar(
                            do { local $_ = $to_coerce; Path::Tiny::path($_) }
                          )
                          : ( ( ref($to_coerce) eq 'ARRAY' ) ) ? scalar(
                            do { local $_ = $to_coerce; Path::Tiny::path(@$_) }
                          )
                          : $to_coerce;
                    };
                    blessed($default_value) && $default_value->isa("Path::Tiny")
                      or croak( "Type check failed in default: %s should be %s",
                        "mite_dir", "Path" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for mite_dir_name
    # has declaration, file lib/Mite/Config.pm, line 11
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "mite_dir_name" => "mite_dir_name" },
        );
    }
    else {
        *mite_dir_name = sub {
            @_ == 1
              or croak('Reader "mite_dir_name" usage: $self->mite_dir_name()');
            $_[0]{"mite_dir_name"};
        };
    }

    # Accessors for search_for_mite_dir
    # has declaration, file lib/Mite/Config.pm, line 46
    sub search_for_mite_dir {
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
            $_[0]{"search_for_mite_dir"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"search_for_mite_dir"} );
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
