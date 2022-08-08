{

    package Mite::Source;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.009003";

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
        # has declaration, file lib/Mite/Source.pm, line 11
        croak "Missing key in constructor: file" unless exists $args->{"file"};
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
            blessed($coerced_value) && $coerced_value->isa("Path::Tiny")
              or croak "Type check failed in constructor: %s should be %s",
              "file", "Path";
            $self->{"file"} = $coerced_value;
        };

        # Attribute classes (type: HashRef[Mite::Class])
        # has declaration, file lib/Mite/Source.pm, line 20
        do {
            my $value =
              exists( $args->{"classes"} )
              ? $args->{"classes"}
              : $Mite::Source::__classes_DEFAULT__->($self);
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
                                  and $i->isa(q[Mite::Class]);
                            }
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "classes", "HashRef[Mite::Class]";
            $self->{"classes"} = $value;
        };

        # Attribute class_order (type: ArrayRef[NonEmptyStr])
        # has declaration, file lib/Mite/Source.pm, line 25
        do {
            my $value =
              exists( $args->{"class_order"} )
              ? $args->{"class_order"}
              : $Mite::Source::__class_order_DEFAULT__->($self);
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
                            && ( length($i) > 0 )
                          );
                    };
                    $ok;
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "class_order", "ArrayRef[NonEmptyStr]";
            $self->{"class_order"} = $value;
        };

        # Attribute compiled (type: Mite::Compiled)
        # has declaration, file lib/Mite/Source.pm, line 34
        if ( exists $args->{"compiled"} ) {
            blessed( $args->{"compiled"} )
              && $args->{"compiled"}->isa("Mite::Compiled")
              or croak "Type check failed in constructor: %s should be %s",
              "compiled", "Mite::Compiled";
            $self->{"compiled"} = $args->{"compiled"};
        }

        # Attribute project (type: Mite::Project)
        # has declaration, file lib/Mite/Source.pm, line 36
        if ( exists $args->{"project"} ) {
            blessed( $args->{"project"} )
              && $args->{"project"}->isa("Mite::Project")
              or croak "Type check failed in constructor: %s should be %s",
              "project", "Mite::Project";
            $self->{"project"} = $args->{"project"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"project"} )
          if ref $self->{"project"};

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown =
          grep not(/\A(?:c(?:lass(?:_order|es)|ompiled)|file|project)\z/),
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

    # Accessors for class_order
    # has declaration, file lib/Mite/Source.pm, line 25
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "class_order" => "class_order" },
        );
    }
    else {
        *class_order = sub {
            @_ == 1
              or croak('Reader "class_order" usage: $self->class_order()');
            $_[0]{"class_order"};
        };
    }

    # Accessors for classes
    # has declaration, file lib/Mite/Source.pm, line 20
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "classes" => "classes" },
        );
    }
    else {
        *classes = sub {
            @_ == 1 or croak('Reader "classes" usage: $self->classes()');
            $_[0]{"classes"};
        };
    }

    # Accessors for compiled
    # has declaration, file lib/Mite/Source.pm, line 34
    sub compiled {
        @_ == 1 or croak('Reader "compiled" usage: $self->compiled()');
        (
            exists( $_[0]{"compiled"} ) ? $_[0]{"compiled"} : (
                $_[0]{"compiled"} = do {
                    my $default_value =
                      $Mite::Source::__compiled_DEFAULT__->( $_[0] );
                    blessed($default_value)
                      && $default_value->isa("Mite::Compiled")
                      or croak( "Type check failed in default: %s should be %s",
                        "compiled", "Mite::Compiled" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for file
    # has declaration, file lib/Mite/Source.pm, line 11
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "file" => "file" },
        );
    }
    else {
        *file = sub {
            @_ == 1 or croak('Reader "file" usage: $self->file()');
            $_[0]{"file"};
        };
    }

    # Accessors for project
    # has declaration, file lib/Mite/Source.pm, line 36
    sub project {
        @_ > 1
          ? do {
            blessed( $_[1] ) && $_[1]->isa("Mite::Project")
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Project" );
            $_[0]{"project"} = $_[1];
            require Scalar::Util && Scalar::Util::weaken( $_[0]{"project"} )
              if ref $_[0]{"project"};
            $_[0];
          }
          : ( $_[0]{"project"} );
    }

    1;
}
