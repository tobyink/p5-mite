{

    package Mite::Compiled;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.012000";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) = ( "Mite::Shim", "Mite::Compiled" );
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

        # Attribute file (type: Path)
        # has declaration, file lib/Mite/Compiled.pm, line 23
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
                  "file", "Path";
                $self->{"file"} = $coerced_value;
            };
        }

        # Attribute source (type: Mite::Source)
        # has declaration, file lib/Mite/Compiled.pm, line 25
        croak "Missing key in constructor: source"
          unless exists $args->{"source"};
        blessed( $args->{"source"} ) && $args->{"source"}->isa("Mite::Source")
          or croak "Type check failed in constructor: %s should be %s",
          "source", "Mite::Source";
        $self->{"source"} = $args->{"source"};
        require Scalar::Util && Scalar::Util::weaken( $self->{"source"} )
          if ref $self->{"source"};

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(/\A(?:file|source)\z/), keys %{$args};
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

    # Accessors for file
    # has declaration, file lib/Mite/Compiled.pm, line 23
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
                  : (
                    do {

                        package Mite::Shim;
                        defined($to_coerce) && !ref($to_coerce)
                          or Scalar::Util::blessed($to_coerce) && (
                            sub {
                                require overload;
                                overload::Overloaded( ref $_[0] or $_[0] )
                                  and overload::Method( ( ref $_[0] or $_[0] ),
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
            blessed($value) && $value->isa("Path::Tiny")
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
                            my $to_coerce =
                              $Mite::Compiled::__file_DEFAULT__->(
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
                                do {
                                    local $_ = $to_coerce;
                                    Path::Tiny::path($_);
                                }
                              )
                              : ( ( ref($to_coerce) eq 'ARRAY' ) ) ? scalar(
                                do {
                                    local $_ = $to_coerce;
                                    Path::Tiny::path(@$_);
                                }
                              )
                              : $to_coerce;
                        };
                        blessed($default_value)
                          && $default_value->isa("Path::Tiny")
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
    # has declaration, file lib/Mite/Compiled.pm, line 25
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "source" => "source" },
        );
    }
    else {
        *source = sub {
            @_ == 1 or croak('Reader "source" usage: $self->source()');
            $_[0]{"source"};
        };
    }

    sub _assert_blessed_source {
        my $object = do { $_[0]{"source"} };
        blessed($object) or croak("source is not a blessed object");
        $object;
    }

    # Delegated methods for source
    # has declaration, file lib/Mite/Compiled.pm, line 25
    sub class_order { shift->_assert_blessed_source->class_order(@_) }
    sub classes     { shift->_assert_blessed_source->classes(@_) }

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

    $SIGNATURE_FOR{"_source_file2compiled_file"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 2
          or croak(
            "Wrong number of parameters in signature for %s: got %d, %s",
            "_source_file2compiled_file",
            scalar(@_),
            "expected exactly 2 parameters"
          );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
        ( defined( $head[0] ) )
          or croak(
"Type check failed in signature for _source_file2compiled_file: %s should be %s",
            "\$_[0]", "Defined"
          );

        # Parameter $_[0] (type: Defined)
        ( defined( $_[0] ) )
          or croak(
"Type check failed in signature for _source_file2compiled_file: %s should be %s",
            "\$_[1]", "Defined"
          );

        do { @_ = ( @head, @_ ); goto $__NEXT__ };
    };

    1;
}
