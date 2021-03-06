{

    package Acme::Mitey::Cards::Suit;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Acme::Mitey::Cards::Mite";
    our $MITE_VERSION = "0.007003";

    BEGIN {
        require Scalar::Util;
        *bare    = \&Acme::Mitey::Cards::Mite::bare;
        *blessed = \&Scalar::Util::blessed;
        *carp    = \&Acme::Mitey::Cards::Mite::carp;
        *confess = \&Acme::Mitey::Cards::Mite::confess;
        *croak   = \&Acme::Mitey::Cards::Mite::croak;
        *false   = \&Acme::Mitey::Cards::Mite::false;
        *guard   = \&Acme::Mitey::Cards::Mite::guard;
        *lazy    = \&Acme::Mitey::Cards::Mite::lazy;
        *ro      = \&Acme::Mitey::Cards::Mite::ro;
        *rw      = \&Acme::Mitey::Cards::Mite::rw;
        *rwp     = \&Acme::Mitey::Cards::Mite::rwp;
        *true    = \&Acme::Mitey::Cards::Mite::true;
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

        # Attribute: name
        croak "Missing key in constructor: name" unless exists $args->{"name"};
        (
            (
                do {

                    package Acme::Mitey::Cards::Mite;
                    defined( $args->{"name"} ) and do {
                        ref( \$args->{"name"} ) eq 'SCALAR'
                          or ref( \( my $val = $args->{"name"} ) ) eq 'SCALAR';
                    }
                }
            )
              && do {

                package Acme::Mitey::Cards::Mite;
                length( $args->{"name"} ) > 0;
            }
          )
          or croak "Type check failed in constructor: %s should be %s", "name",
          "NonEmptyStr";
        $self->{"name"} = $args->{"name"};

        # Attribute: abbreviation
        if ( exists $args->{"abbreviation"} ) {
            do {

                package Acme::Mitey::Cards::Mite;
                defined( $args->{"abbreviation"} ) and do {
                    ref( \$args->{"abbreviation"} ) eq 'SCALAR'
                      or ref( \( my $val = $args->{"abbreviation"} ) ) eq
                      'SCALAR';
                }
              }
              or croak "Type check failed in constructor: %s should be %s",
              "abbreviation", "Str";
            $self->{"abbreviation"} = $args->{"abbreviation"};
        }

        # Attribute: colour
        croak "Missing key in constructor: colour"
          unless exists $args->{"colour"};
        do {

            package Acme::Mitey::Cards::Mite;
            defined( $args->{"colour"} ) and do {
                ref( \$args->{"colour"} ) eq 'SCALAR'
                  or ref( \( my $val = $args->{"colour"} ) ) eq 'SCALAR';
            }
          }
          or croak "Type check failed in constructor: %s should be %s",
          "colour", "Str";
        $self->{"colour"} = $args->{"colour"};

        # Enforce strict constructor
        my @unknown = grep not(/\A(?:abbreviation|colour|name)\z/),
          keys %{$args};
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

    # Accessors for abbreviation
    sub abbreviation {
        @_ > 1
          ? croak("abbreviation is a read-only attribute of @{[ref $_[0]]}")
          : (
            exists( $_[0]{"abbreviation"} ) ? $_[0]{"abbreviation"} : (
                $_[0]{"abbreviation"} = do {
                    my $default_value = $_[0]->_build_abbreviation;
                    do {

                        package Acme::Mitey::Cards::Mite;
                        defined($default_value) and do {
                            ref( \$default_value ) eq 'SCALAR'
                              or ref( \( my $val = $default_value ) ) eq
                              'SCALAR';
                        }
                      }
                      or croak( "Type check failed in default: %s should be %s",
                        "abbreviation", "Str" );
                    $default_value;
                }
            )
          );
    }

    # Accessors for colour
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "colour" => "colour" },
        );
    }
    else {
        *colour = sub {
            @_ > 1
              ? croak("colour is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"colour"};
        };
    }

    # Accessors for name
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "name" => "name" },
        );
    }
    else {
        *name = sub {
            @_ > 1
              ? croak("name is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"name"};
        };
    }

    our %SIGNATURE_FOR;

    $SIGNATURE_FOR{"clubs"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "clubs", "expected exactly 1 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or croak( "Type check failed in signature for clubs: %s should be %s",
            "\$_[0]", "Defined" );

        return ( &$__NEXT__( @head, @_ ) );
    };

    $SIGNATURE_FOR{"diamonds"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "diamonds", "expected exactly 1 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or
          croak( "Type check failed in signature for diamonds: %s should be %s",
            "\$_[0]", "Defined" );

        return ( &$__NEXT__( @head, @_ ) );
    };

    $SIGNATURE_FOR{"hearts"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "hearts", "expected exactly 1 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or
          croak( "Type check failed in signature for hearts: %s should be %s",
            "\$_[0]", "Defined" );

        return ( &$__NEXT__( @head, @_ ) );
    };

    $SIGNATURE_FOR{"spades"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "spades", "expected exactly 1 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or
          croak( "Type check failed in signature for spades: %s should be %s",
            "\$_[0]", "Defined" );

        return ( &$__NEXT__( @head, @_ ) );
    };

    $SIGNATURE_FOR{"standard_suits"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "standard_suits", "expected exactly 1 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or croak(
"Type check failed in signature for standard_suits: %s should be %s",
            "\$_[0]", "Defined"
          );

        return ( &$__NEXT__( @head, @_ ) );
    };

    1;
}
