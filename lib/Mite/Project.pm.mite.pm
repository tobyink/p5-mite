{

    package Mite::Project;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.007001";

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

        # Attribute: sources
        do {
            my $value =
              exists( $args->{"sources"} )
              ? $args->{"sources"}
              : $Mite::Project::__sources_DEFAULT__->($self);
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
                                  and $i->isa(q[Mite::Source]);
                            }
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "sources", "HashRef[Mite::Source]";
            $self->{"sources"} = $value;
        };

        # Attribute: config
        if ( exists $args->{"config"} ) {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"config"} )
                      and $args->{"config"}->isa(q[Mite::Config]);
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "config", "Mite::Config";
            $self->{"config"} = $args->{"config"};
        }

        # Attribute: _compiling_self
        do {
            my $value =
              exists( $args->{"_compiling_self"} )
              ? $args->{"_compiling_self"}
              : "";
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "_compiling_self", "Bool";
            $self->{"_compiling_self"} = $value;
        };

        # Attribute: _module_fakeout_namespace
        if ( exists $args->{"_module_fakeout_namespace"} ) {
            do {

                package Mite::Shim;
                (
                    do {

                        package Mite::Shim;
                        defined( $args->{"_module_fakeout_namespace"} ) and do {
                            ref( \$args->{"_module_fakeout_namespace"} ) eq
                              'SCALAR'
                              or ref(
                                \(
                                    my $val =
                                      $args->{"_module_fakeout_namespace"}
                                )
                              ) eq 'SCALAR';
                        }
                      }
                      or do {

                        package Mite::Shim;
                        !defined( $args->{"_module_fakeout_namespace"} );
                    }
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "_module_fakeout_namespace", "Str|Undef";
            $self->{"_module_fakeout_namespace"} =
              $args->{"_module_fakeout_namespace"};
        }

        # Attribute: debug
        do {
            my $value = exists( $args->{"debug"} ) ? $args->{"debug"} : "";
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "debug", "Bool";
            $self->{"debug"} = $value;
        };

        # Enforce strict constructor
        my @unknown = grep not(
/\A(?:_(?:compiling_self|module_fakeout_namespace)|config|debug|sources)\z/
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

    # Accessors for _compiling_self
    sub _compiling_self {
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
            $_[0]{"_compiling_self"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"_compiling_self"} );
    }

    # Accessors for _module_fakeout_namespace
    sub _module_fakeout_namespace {
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
            $_[0]{"_module_fakeout_namespace"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"_module_fakeout_namespace"} );
    }

    # Accessors for config
    sub config {
        @_ > 1 ? croak("config is a read-only attribute of @{[ref $_[0]]}") : (
            exists( $_[0]{"config"} ) ? $_[0]{"config"} : (
                $_[0]{"config"} = do {
                    my $default_value =
                      $Mite::Project::__config_DEFAULT__->( $_[0] );
                    (
                        do {
                            use Scalar::Util ();
                            Scalar::Util::blessed($default_value)
                              and $default_value->isa(q[Mite::Config]);
                        }
                      )
                      or croak( "Type check failed in default: %s should be %s",
                        "config", "Mite::Config" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for debug
    sub debug {
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
            $_[0]{"debug"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"debug"} );
    }

    # Accessors for sources
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "sources" => "sources" },
        );
    }
    else {
        *sources = sub {
            @_ > 1
              ? croak("sources is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"sources"};
        };
    }

    1;
}
