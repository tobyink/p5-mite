{

    package Mite::Project;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.013000";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) = ( "Mite::Shim", "Mite::Project" );
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
        *lock    = \&Mite::Shim::lock;
        *ro      = \&Mite::Shim::ro;
        *rw      = \&Mite::Shim::rw;
        *rwp     = \&Mite::Shim::rwp;
        *true    = \&Mite::Shim::true;
        *unlock  = \&Mite::Shim::unlock;
    }

    # Gather metadata for constructor and destructor
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
                map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
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

        # Attribute sources (type: HashRef[Mite::Source])
        # has declaration, file lib/Mite/Project.pm, line 14
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

        # Attribute config (type: Mite::Config)
        # has declaration, file lib/Mite/Project.pm, line 24
        if ( exists $args->{"config"} ) {
            blessed( $args->{"config"} )
              && $args->{"config"}->isa("Mite::Config")
              or croak "Type check failed in constructor: %s should be %s",
              "config", "Mite::Config";
            $self->{"config"} = $args->{"config"};
        }

        # Attribute _module_fakeout_namespace (type: Str|Undef)
        # has declaration, file lib/Mite/Project.pm, line 26
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

        # Attribute debug (type: Bool)
        # has declaration, file lib/Mite/Project.pm, line 30
        do {
            my $value = exists( $args->{"debug"} ) ? $args->{"debug"} : false;
            (
                !ref $value
                  and ( !defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "debug", "Bool";
            $self->{"debug"} = $value;
        };

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown =
          grep not(/\A(?:_module_fakeout_namespace|config|debug|sources)\z/),
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

    my $__XS = !$ENV{PERL_ONLY}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for _module_fakeout_namespace
    # has declaration, file lib/Mite/Project.pm, line 26
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
    # has declaration, file lib/Mite/Project.pm, line 24
    sub config {
        @_ == 1 or croak('Reader "config" usage: $self->config()');
        (
            exists( $_[0]{"config"} ) ? $_[0]{"config"} : (
                $_[0]{"config"} = do {
                    my $default_value =
                      $Mite::Project::__config_DEFAULT__->( $_[0] );
                    blessed($default_value)
                      && $default_value->isa("Mite::Config")
                      or croak( "Type check failed in default: %s should be %s",
                        "config", "Mite::Config" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for debug
    # has declaration, file lib/Mite/Project.pm, line 30
    sub debug {
        @_ > 1
          ? do {
            (
                !ref $_[1]
                  and ( !defined $_[1]
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
    # has declaration, file lib/Mite/Project.pm, line 14
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "sources" => "sources" },
        );
    }
    else {
        *sources = sub {
            @_ == 1 or croak('Reader "sources" usage: $self->sources()');
            $_[0]{"sources"};
        };
    }

    # See UNIVERSAL
    sub DOES {
        my ( $self, $role ) = @_;
        our %DOES;
        return $DOES{$role} if exists $DOES{$role};
        return 1            if $role eq __PACKAGE__;
        if ( $INC{'Moose/Util.pm'}
            and my $meta = Moose::Util::find_meta( ref $self or $self ) )
        {
            $meta->can('does_role') and $meta->does_role($role) and return 1;
        }
        return $self->SUPER::DOES($role);
    }

    # Alias for Moose/Moo-compatibility
    sub does {
        shift->DOES(@_);
    }

    # Method signatures
    our %SIGNATURE_FOR;

    $SIGNATURE_FOR{"_recurse_directory"} = sub {
        my $__NEXT__ = shift;

        my ( @out, %tmp, $tmp, $dtmp, @head );

        @_ == 3
          or
          croak( "Wrong number of parameters in signature for %s: got %d, %s",
            "_recurse_directory", scalar(@_), "expected exactly 3 parameters" );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
        ( defined( $head[0] ) )
          or croak(
"Type check failed in signature for _recurse_directory: %s should be %s",
            "\$_[0]", "Defined"
          );

        # Parameter $_[0] (type: Path)
        $tmp = (
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $_[0] ) and $_[0]->isa(q[Path::Tiny]);
                }
            )
        ) ? $_[0] : (
            do {

                package Mite::Shim;
                defined( $_[0] ) and do {
                    ref( \$_[0] ) eq 'SCALAR'
                      or ref( \( my $val = $_[0] ) ) eq 'SCALAR';
                }
            }
          )
          ? scalar(
            do { local $_ = $_[0]; Path::Tiny::path($_) }
          )
          : (
            do {

                package Mite::Shim;
                defined( $_[0] ) && !ref( $_[0] )
                  or Scalar::Util::blessed( $_[0] ) && (
                    sub {
                        require overload;
                        overload::Overloaded( ref $_[0] or $_[0] )
                          and overload::Method( ( ref $_[0] or $_[0] ), $_[1] );
                    }
                )->( $_[0], q[""] );
            }
          )
          ? scalar(
            do { local $_ = $_[0]; Path::Tiny::path($_) }
          )
          : ( ( ref( $_[0] ) eq 'ARRAY' ) ) ? scalar(
            do { local $_ = $_[0]; Path::Tiny::path(@$_) }
          )
          : $_[0];
        (
            do {
                use Scalar::Util ();
                Scalar::Util::blessed($tmp) and $tmp->isa(q[Path::Tiny]);
            }
          )
          or croak(
"Type check failed in signature for _recurse_directory: %s should be %s",
            "\$_[1]", "Path"
          );
        push( @out, $tmp );

        # Parameter $_[1] (type: CodeRef)
        ( ref( $_[1] ) eq 'CODE' )
          or croak(
"Type check failed in signature for _recurse_directory: %s should be %s",
            "\$_[2]", "CodeRef"
          );
        push( @out, $_[1] );

        do { @_ = ( @head, @out ); goto $__NEXT__ };
    };

    $SIGNATURE_FOR{"inject_mite_functions"} = sub {
        my $__NEXT__ = shift;

        my ( %out, %in, %tmp, $tmp, $dtmp, @head );

        @_ == 2 && ( ref( $_[1] ) eq 'HASH' )
          or @_ % 2 == 1 && @_ >= 7
          or
          croak( "Wrong number of parameters in signature for %s: got %d, %s",
            "inject_mite_functions", scalar(@_), "that does not seem right" );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
        ( defined( $head[0] ) )
          or croak(
"Type check failed in signature for inject_mite_functions: %s should be %s",
            "\$_[0]", "Defined"
          );

        %in = ( @_ == 1 and ( ref( $_[0] ) eq 'HASH' ) ) ? %{ $_[0] } : @_;

        # Parameter package (type: Any)
        exists( $in{"package"} )
          or croak( "Failure in signature for inject_mite_functions: "
              . 'Missing required parameter: package' );
        1;    # ... nothing to do
        $out{"package"} = $in{"package"} if exists( $in{"package"} );
        delete( $in{"package"} );

        # Parameter file (type: Any)
        exists( $in{"file"} )
          or croak( "Failure in signature for inject_mite_functions: "
              . 'Missing required parameter: file' );
        1;    # ... nothing to do
        $out{"file"} = $in{"file"} if exists( $in{"file"} );
        delete( $in{"file"} );

        # Parameter kind (type: Optional[Str])
        if ( exists( $in{"kind"} ) ) {
            do {

                package Mite::Shim;
                defined( $in{"kind"} ) and do {
                    ref( \$in{"kind"} ) eq 'SCALAR'
                      or ref( \( my $val = $in{"kind"} ) ) eq 'SCALAR';
                }
              }
              or croak(
"Type check failed in signature for inject_mite_functions: %s should be %s",
                "\$_{\"kind\"}", "Optional[Str]"
              );
            $out{"kind"} = $in{"kind"};
            delete( $in{"kind"} );
        }

        # Parameter arg (type: HashRef)
        $dtmp = exists( $in{"arg"} ) ? $in{"arg"} : {};
        ( ref($dtmp) eq 'HASH' )
          or croak(
"Type check failed in signature for inject_mite_functions: %s should be %s",
            "\$_{\"arg\"}", "HashRef"
          );
        $out{"arg"} = $dtmp;
        delete( $in{"arg"} );

        # Parameter shim (type: Str)
        exists( $in{"shim"} )
          or croak( "Failure in signature for inject_mite_functions: "
              . 'Missing required parameter: shim' );
        do {

            package Mite::Shim;
            defined( $in{"shim"} ) and do {
                ref( \$in{"shim"} ) eq 'SCALAR'
                  or ref( \( my $val = $in{"shim"} ) ) eq 'SCALAR';
            }
          }
          or croak(
"Type check failed in signature for inject_mite_functions: %s should be %s",
            "\$_{\"shim\"}", "Str"
          );
        $out{"shim"} = $in{"shim"} if exists( $in{"shim"} );
        delete( $in{"shim"} );

        # Parameter x_source (type: Optional[Object])
        if ( exists( $in{"x_source"} ) ) {
            (
                do {

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $in{"x_source"} );
                }
              )
              or croak(
"Type check failed in signature for inject_mite_functions: %s should be %s",
                "\$_{\"x_source\"}", "Optional[Object]"
              );
            $out{"x_source"} = $in{"x_source"};
            delete( $in{"x_source"} );
        }

        # Parameter x_pkg (type: Optional[Object])
        if ( exists( $in{"x_pkg"} ) ) {
            (
                do {

                    package Mite::Shim;
                    use Scalar::Util ();
                    Scalar::Util::blessed( $in{"x_pkg"} );
                }
              )
              or croak(
"Type check failed in signature for inject_mite_functions: %s should be %s",
                "\$_{\"x_pkg\"}", "Optional[Object]"
              );
            $out{"x_pkg"} = $in{"x_pkg"};
            delete( $in{"x_pkg"} );
        }

        # Unrecognized parameters
        croak(
            "Failure in signature for inject_mite_functions: "
              . sprintf(
                q{Unrecognized parameter%s: %s},
                keys(%in) > 1 ? q{s} : q{},
                join q{, } => ( sort keys %in )
              )
        ) if keys %in;

        do {
            @_ = (
                @head,       $out{"package"}, $out{"file"},     $out{"kind"},
                $out{"arg"}, $out{"shim"},    $out{"x_source"}, $out{"x_pkg"}
            );
            goto $__NEXT__;
        };
    };

    $SIGNATURE_FOR{"load_files"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ >= 2 && @_ <= 3
          or
          croak( "Wrong number of parameters in signature for %s: got %d, %s",
            "load_files", scalar(@_), "expected exactly 2 parameters" );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
        ( defined( $head[0] ) )
          or croak(
            "Type check failed in signature for load_files: %s should be %s",
            "\$_[0]", "Defined" );

        # Parameter $_[0] (type: ArrayRef)
        ( ref( $_[0] ) eq 'ARRAY' )
          or croak(
            "Type check failed in signature for load_files: %s should be %s",
            "\$_[1]", "ArrayRef" );

        # Parameter $_[1] (type: Any)
        $#_ >= 1
          or do { @_ = ( @head, @_ ); goto $__NEXT__ };
        1;    # ... nothing to do

        do { @_ = ( @head, @_ ); goto $__NEXT__ };
    };

    1;
}
