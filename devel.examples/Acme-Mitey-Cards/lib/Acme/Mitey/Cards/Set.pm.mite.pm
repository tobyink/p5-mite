{

    package Acme::Mitey::Cards::Set;
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

        # Attribute: cards
        if ( exists $args->{"cards"} ) {
            (
                do {

                    package Acme::Mitey::Cards::Mite;
                    ref( $args->{"cards"} ) eq 'ARRAY';
                  }
                  and do {
                    my $ok = 1;
                    for my $i ( @{ $args->{"cards"} } ) {
                        ( $ok = 0, last )
                          unless (
                            do {
                                use Scalar::Util ();
                                Scalar::Util::blessed($i)
                                  and $i->isa(q[Acme::Mitey::Cards::Card]);
                            }
                          );
                    };
                    $ok;
                }
              )
              or croak "Type check failed in constructor: %s should be %s",
              "cards", "CardArray";
            $self->{"cards"} = $args->{"cards"};
        }

        # Enforce strict constructor
        my @unknown = grep not(/\Acards\z/), keys %{$args};
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

    # Accessors for cards
    sub cards {
        @_ > 1 ? croak("cards is a read-only attribute of @{[ref $_[0]]}") : (
            exists( $_[0]{"cards"} ) ? $_[0]{"cards"} : (
                $_[0]{"cards"} = do {
                    my $default_value = $_[0]->_build_cards;
                    do {

                        package Acme::Mitey::Cards::Mite;
                        ( ref($default_value) eq 'ARRAY' ) and do {
                            my $ok = 1;
                            for my $i ( @{$default_value} ) {
                                ( $ok = 0, last )
                                  unless (
                                    do {
                                        use Scalar::Util ();
                                        Scalar::Util::blessed($i)
                                          and
                                          $i->isa(q[Acme::Mitey::Cards::Card]);
                                    }
                                  );
                            };
                            $ok;
                        }
                      }
                      or croak( "Type check failed in default: %s should be %s",
                        "cards", "CardArray" );
                    $default_value;
                }
            )
        );
    }

    our %SIGNATURE_FOR;

    $SIGNATURE_FOR{"count"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "count", "expected exactly 1 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or croak( "Type check failed in signature for count: %s should be %s",
            "\$_[0]", "Defined" );

        return ( &$__NEXT__( @head, @_ ) );
    };

    $SIGNATURE_FOR{"take"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 2
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "take", "expected exactly 2 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or croak( "Type check failed in signature for take: %s should be %s",
            "\$_[0]", "Defined" );

        # Parameter $_[0] (type: Int)
        (
            do {
                my $tmp = $_[0];
                defined($tmp) and !ref($tmp) and $tmp =~ /\A-?[0-9]+\z/;
            }
          )
          or croak( "Type check failed in signature for take: %s should be %s",
            "\$_[1]", "Int" );

        return ( &$__NEXT__( @head, @_ ) );
    };

    $SIGNATURE_FOR{"to_string"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or croak(
            "Wrong number of parameters in signature for %s: %s, got %d",
            "to_string", "expected exactly 1 parameters",
            scalar(@_)
          );

        @head = splice( @_, 0, 1 );

        # Parameter $head[0] (type: Defined)
        ( defined( $head[0] ) )
          or croak(
            "Type check failed in signature for to_string: %s should be %s",
            "\$_[0]", "Defined" );

        return ( &$__NEXT__( @head, @_ ) );
    };

    1;
}
