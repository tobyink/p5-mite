{

    package Acme::Mitey::Cards::Set;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Acme::Mitey::Cards::Mite";
    our $MITE_VERSION = "0.012000";

    # Mite keywords
    BEGIN {
        my ( $SHIM, $CALLER ) =
          ( "Acme::Mitey::Cards::Mite", "Acme::Mitey::Cards::Set" );
        (
            *after, *around, *before,        *extends, *field,
            *has,   *param,  *signature_for, *with
          )
          = do {

            package Acme::Mitey::Cards::Mite;
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
        *STRICT  = \&Acme::Mitey::Cards::Mite::STRICT;
        *bare    = \&Acme::Mitey::Cards::Mite::bare;
        *blessed = \&Scalar::Util::blessed;
        *carp    = \&Acme::Mitey::Cards::Mite::carp;
        *confess = \&Acme::Mitey::Cards::Mite::confess;
        *croak   = \&Acme::Mitey::Cards::Mite::croak;
        *false   = \&Acme::Mitey::Cards::Mite::false;
        *guard   = \&Acme::Mitey::Cards::Mite::guard;
        *lazy    = \&Acme::Mitey::Cards::Mite::lazy;
        *lock    = \&Acme::Mitey::Cards::Mite::lock;
        *ro      = \&Acme::Mitey::Cards::Mite::ro;
        *rw      = \&Acme::Mitey::Cards::Mite::rw;
        *rwp     = \&Acme::Mitey::Cards::Mite::rwp;
        *true    = \&Acme::Mitey::Cards::Mite::true;
        *unlock  = \&Acme::Mitey::Cards::Mite::unlock;
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

    # Moose-compatibility method
    sub meta {
        require Acme::Mitey::Cards::MOP;
        Moose::Util::find_meta( ref $_[0] or $_[0] );
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

        # Attribute cards (type: CardArray)
        # has declaration, file lib/Acme/Mitey/Cards/Set.pm, line 11
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

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(/\Acards\z/), keys %{$args};
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

    # Accessors for cards
    # has declaration, file lib/Acme/Mitey/Cards/Set.pm, line 11
    sub cards {
        @_ == 1 or croak('Reader "cards" usage: $self->cards()');
        (
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

    $SIGNATURE_FOR{"count"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or
          croak( "Wrong number of parameters in signature for %s: got %d, %s",
            "count", scalar(@_), "expected exactly 1 parameters" );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
        ( defined( $head[0] ) )
          or croak( "Type check failed in signature for count: %s should be %s",
            "\$_[0]", "Defined" );

        do { @_ = ( @head, @_ ); goto $__NEXT__ };
    };

    $SIGNATURE_FOR{"take"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 2
          or
          croak( "Wrong number of parameters in signature for %s: got %d, %s",
            "take", scalar(@_), "expected exactly 2 parameters" );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
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

        do { @_ = ( @head, @_ ); goto $__NEXT__ };
    };

    $SIGNATURE_FOR{"to_string"} = sub {
        my $__NEXT__ = shift;

        my ( %tmp, $tmp, @head );

        @_ == 1
          or
          croak( "Wrong number of parameters in signature for %s: got %d, %s",
            "to_string", scalar(@_), "expected exactly 1 parameters" );

        @head = splice( @_, 0, 1 );

        # Parameter invocant (type: Defined)
        ( defined( $head[0] ) )
          or croak(
            "Type check failed in signature for to_string: %s should be %s",
            "\$_[0]", "Defined" );

        do { @_ = ( @head, @_ ); goto $__NEXT__ };
    };

    1;
}
