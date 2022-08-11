{

    package Mite::App::Command::compile;
    use strict;
    use warnings;
    no warnings qw( once void );

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.010001";

    # Mite keywords
    BEGIN {
        my $CALLER = "Mite::App::Command::compile";
        (
            *after, *around, *before,        *extends, *field,
            *has,   *param,  *signature_for, *with
          )
          = do {

            package Mite::Shim;
            no warnings 'redefine';
            (
                sub { __PACKAGE__->HANDLE_after( $CALLER, "class", @_ ) },
                sub { __PACKAGE__->HANDLE_around( $CALLER, "class", @_ ) },
                sub { __PACKAGE__->HANDLE_before( $CALLER, "class", @_ ) },
                sub { },
                sub { __PACKAGE__->HANDLE_has( $CALLER, field => @_ ) },
                sub { __PACKAGE__->HANDLE_has( $CALLER, has   => @_ ) },
                sub { __PACKAGE__->HANDLE_has( $CALLER, param => @_ ) },
                sub { __PACKAGE__->HANDLE_signature_for( $CALLER, @_ ) },
                sub { __PACKAGE__->HANDLE_with( $CALLER, @_ ) },
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

    BEGIN {
        require Mite::App::Command;
        "Mite::App::Command"->VERSION("0.009000");
        use mro 'c3';
        our @ISA;
        push @ISA, "Mite::App::Command";
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
