{
package Mite::Project;
our $USES_MITE = "Mite::Class";
use strict;
use warnings;


sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    if ( exists $args->{"sources"} ) { (do { package Mite::Miteception; ref($args->{"sources"}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{"sources"}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Source]) }) }; $ok }) or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "sources", "HashRef[InstanceOf[\"Mite::Source\"]]"); $self->{"sources"} = $args->{"sources"};  } else { my $value = do { my $default_value = do { my $method = $Mite::Project::__sources_DEFAULT__; $self->$method }; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Source]) }) }; $ok } } or do { require Carp; Carp::croak(sprintf "Type check failed in default: %s should be %s", "sources", "HashRef[InstanceOf[\"Mite::Source\"]]") }; $default_value }; $self->{"sources"} = $value;  };
    if ( exists $args->{"config"} ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{"config"}) and $args->{"config"}->isa(q[Mite::Config]) }) or require Carp && Carp::croak(sprintf "Type check failed in constructor: %s should be %s", "config", "InstanceOf[\"Mite::Config\"]"); $self->{"config"} = $args->{"config"};  };

    # Enforce strict constructor
    my @unknown = grep not( /\A(?:config|sources)\z/ ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

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

my $__XS = !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

# Accessors for config
sub config { @_ > 1 ? require Carp && Carp::croak("config is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{"config"}) ? $_[0]{"config"} : ( $_[0]{"config"} = do { my $default_value = do { my $method = $Mite::Project::__config_DEFAULT__; $_[0]->$method }; (do { use Scalar::Util (); Scalar::Util::blessed($default_value) and $default_value->isa(q[Mite::Config]) }) or do { require Carp; Carp::croak(sprintf "Type check failed in default: %s should be %s", "config", "InstanceOf[\"Mite::Config\"]") }; $default_value } ) ) }

# Accessors for sources
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "sources" => "sources" },
    );
}
else {
    *sources = sub { @_ > 1 ? require Carp && Carp::croak("sources is a read-only attribute of @{[ref $_[0]]}") : $_[0]{"sources"} };
}


1;
}