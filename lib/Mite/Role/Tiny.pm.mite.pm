{
package Mite::Role::Tiny;
our $USES_MITE = "Mite::Class";
use strict;
use warnings;

BEGIN {
    require Mite::Role;

    use mro 'c3';
    our @ISA;
    push @ISA, "Mite::Role";
}

sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    if ( exists $args->{"attributes"} ) { (do { package Mite::Miteception; ref($args->{"attributes"}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{"attributes"}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok }) or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "attributes", "HashRef[InstanceOf[\"Mite::Attribute\"]]"); $self->{"attributes"} = $args->{"attributes"};  } else { my $value = do { my $default_value = do { my $method = $Mite::Role::__attributes_DEFAULT__; $self->$method }; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok } } or do { require Carp; Carp::croak(sprintf "Type check failed in default: %s should be %s", "attributes", "HashRef[InstanceOf[\"Mite::Attribute\"]]") }; $default_value }; $self->{"attributes"} = $value;  };
    if ( exists $args->{"name"} ) { do { package Mite::Miteception; defined($args->{"name"}) and do { ref(\$args->{"name"}) eq 'SCALAR' or ref(\(my $val = $args->{"name"})) eq 'SCALAR' } } or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "name", "Str"); $self->{"name"} = $args->{"name"};  } else { require Carp; Carp::croak("Missing key in constructor: name") };
    if ( exists $args->{"shim_name"} ) { do { package Mite::Miteception; defined($args->{"shim_name"}) and do { ref(\$args->{"shim_name"}) eq 'SCALAR' or ref(\(my $val = $args->{"shim_name"})) eq 'SCALAR' } } or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "shim_name", "Str"); $self->{"shim_name"} = $args->{"shim_name"};  };
    if ( exists $args->{"source"} ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{"source"}) and $args->{"source"}->isa(q[Mite::Source]) }) or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "source", "InstanceOf[\"Mite::Source\"]"); $self->{"source"} = $args->{"source"};  } require Scalar::Util && Scalar::Util::weaken($self->{"source"});
    if ( exists $args->{"roles"} ) { do { package Mite::Miteception; ref($args->{"roles"}) eq 'ARRAY' } or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "roles", "ArrayRef"); $self->{"roles"} = $args->{"roles"};  } else { my $value = do { my $default_value = $self->_build_roles; (ref($default_value) eq 'ARRAY') or do { require Carp; Carp::croak(sprintf "Type check failed in default: %s should be %s", "roles", "ArrayRef") }; $default_value }; $self->{"roles"} = $value;  };
    if ( exists $args->{"constants"} ) { do { package Mite::Miteception; ref($args->{"constants"}) eq 'HASH' } or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "constants", "HashRef"); $self->{"constants"} = $args->{"constants"};  } else { my $value = do { my $default_value = $self->_build_constants; (ref($default_value) eq 'HASH') or do { require Carp; Carp::croak(sprintf "Type check failed in default: %s should be %s", "constants", "HashRef") }; $default_value }; $self->{"constants"} = $value;  };

    # Enforce strict constructor
    my @unknown = grep not( /\A(?:attributes|constants|name|roles|s(?:him_name|ource))\z/ ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

    # Call BUILD methods
    unless ( $no_build ) { $_->($self, $args) for @{ $meta->{BUILD} || [] } };

    return $self;
}

sub DESTROY {
    my $self  = shift;
    my $class = ref( $self ) || $self;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $in_global_destruction = defined ${^GLOBAL_PHASE}
        ? ${^GLOBAL_PHASE} eq 'DESTRUCT'
        : Devel::GlobalDestruction::in_global_destruction();
    for my $demolisher ( @{ $meta->{DEMOLISH} || [] } ) {
        my $e = do {
            local ( $?, $@ );
            eval { $demolisher->( $self, $in_global_destruction ) };
            $@;
        };
        no warnings 'misc'; # avoid (in cleanup) warnings
        die $e if $e;       # rethrow
    }
    return;
}

sub __META__ {
    no strict 'refs';
    my $class      = shift; $class = ref($class) || $class;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
    };
}

sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    return $self->SUPER::DOES( $role );
}

sub does {
    shift->DOES( @_ );
}


1;
}