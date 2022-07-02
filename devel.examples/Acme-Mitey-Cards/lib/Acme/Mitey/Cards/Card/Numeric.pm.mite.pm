{

    package Acme::Mitey::Cards::Card::Numeric;
    our $USES_MITE = "Mite::Class";
    use strict;
    use warnings;

    BEGIN {
        require Acme::Mitey::Cards::Card;

        use mro 'c3';
        our @ISA;
        push @ISA, "Acme::Mitey::Cards::Card";
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

        # Initialize attributes
        if ( exists $args->{"deck"} ) {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"deck"} )
                      and $args->{"deck"}->isa(q[Acme::Mitey::Cards::Deck]);
                }
              )
              or require Carp
              && Carp::croak(
                sprintf "Type check failed in constructor: %s should be %s",
                "deck", "InstanceOf[\"Acme::Mitey::Cards::Deck\"]" );
            $self->{"deck"} = $args->{"deck"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"deck"} );
        if ( exists $args->{"number"} ) {
            (
                do {
                    my $tmp = $args->{"number"};
                    defined($tmp) and !ref($tmp) and $tmp =~ /\A-?[0-9]+\z/;
                }
              )
              or require Carp
              && Carp::croak(
                sprintf "Type check failed in constructor: %s should be %s",
                "number", "Int" );
            $self->{"number"} = $args->{"number"};
        }
        else { require Carp; Carp::croak("Missing key in constructor: number") }
        if ( exists $args->{"reverse"} ) {
            do {

                package Acme::Mitey::Cards::Mite;
                defined( $args->{"reverse"} ) and do {
                    ref( \$args->{"reverse"} ) eq 'SCALAR'
                      or ref( \( my $val = $args->{"reverse"} ) ) eq 'SCALAR';
                }
              }
              or require Carp
              && Carp::croak(
                sprintf "Type check failed in constructor: %s should be %s",
                "reverse", "Str" );
            $self->{"reverse"} = $args->{"reverse"};
        }
        if ( exists $args->{"suit"} ) {
            (
                do {
                    use Scalar::Util ();
                    Scalar::Util::blessed( $args->{"suit"} )
                      and $args->{"suit"}->isa(q[Acme::Mitey::Cards::Suit]);
                }
              )
              or require Carp
              && Carp::croak(
                sprintf "Type check failed in constructor: %s should be %s",
                "suit", "InstanceOf[\"Acme::Mitey::Cards::Suit\"]" );
            $self->{"suit"} = $args->{"suit"};
        }
        else { require Carp; Carp::croak("Missing key in constructor: suit") }

        # Enforce strict constructor
        my @unknown = grep not(/\A(?:deck|number|reverse|suit)\z/),
          keys %{$args};
        @unknown
          and require Carp
          and Carp::croak(
            "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

        # Call BUILD methods
        unless ($no_build) {
            $_->( $self, $args ) for @{ $meta->{BUILD} || [] };
        }

        return $self;
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
        require mro;
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
            HAS_BUILDARGS => $class->can('BUILDARGS'),
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

    # Accessors for number
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "number" => "number" },
        );
    }
    else {
        *number = sub {
            @_ > 1
              ? require Carp && Carp::croak(
                "number is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"number"};
        };
    }

    # Accessors for suit
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "suit" => "suit" },
        );
    }
    else {
        *suit = sub {
            @_ > 1
              ? require Carp
              && Carp::croak("suit is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"suit"};
        };
    }

    1;
}
