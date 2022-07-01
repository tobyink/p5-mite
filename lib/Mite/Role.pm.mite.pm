{
package Mite::Role;
our $USES_MITE = q[Mite::Class];
use strict;
use warnings;


sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    if ( exists($args->{q[attributes]}) ) { (do { package Mite::Miteception; ref($args->{q[attributes]}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{q[attributes]}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok }) or require Carp && Carp::croak(q[Type check failed in constructor: attributes should be HashRef[InstanceOf["Mite::Attribute"]]]); $self->{q[attributes]} = $args->{q[attributes]};  } else { my $value = do { my $default_value = do { my $method = $Mite::Role::__attributes_DEFAULT__; $self->$method }; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: attributes should be HashRef[InstanceOf["Mite::Attribute"]]]) }; $default_value }; $self->{q[attributes]} = $value;  }
    if ( exists($args->{q[method_modifiers]}) ) { do { package Mite::Miteception; ref($args->{q[method_modifiers]}) eq 'ARRAY' } or require Carp && Carp::croak(q[Type check failed in constructor: method_modifiers should be ArrayRef]); $self->{q[method_modifiers]} = $args->{q[method_modifiers]};  } else { my $value = do { my $default_value = $self->_build_method_modifiers; (ref($default_value) eq 'ARRAY') or do { require Carp; Carp::croak(q[Type check failed in default: method_modifiers should be ArrayRef]) }; $default_value }; $self->{q[method_modifiers]} = $value;  }
    if ( exists($args->{q[name]}) ) { do { package Mite::Miteception; defined($args->{q[name]}) and do { ref(\$args->{q[name]}) eq 'SCALAR' or ref(\(my $val = $args->{q[name]})) eq 'SCALAR' } } or require Carp && Carp::croak(q[Type check failed in constructor: name should be Str]); $self->{q[name]} = $args->{q[name]};  } else { require Carp; Carp::croak("Missing key in constructor: name") }
    if ( exists($args->{q[roles]}) ) { do { package Mite::Miteception; ref($args->{q[roles]}) eq 'ARRAY' } or require Carp && Carp::croak(q[Type check failed in constructor: roles should be ArrayRef]); $self->{q[roles]} = $args->{q[roles]};  } else { my $value = do { my $default_value = $self->_build_roles; (ref($default_value) eq 'ARRAY') or do { require Carp; Carp::croak(q[Type check failed in default: roles should be ArrayRef]) }; $default_value }; $self->{q[roles]} = $value;  }
    if ( exists($args->{q[source]}) ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{q[source]}) and $args->{q[source]}->isa(q[Mite::Source]) }) or require Carp && Carp::croak(q[Type check failed in constructor: source should be InstanceOf["Mite::Source"]]); $self->{q[source]} = $args->{q[source]};  } require Scalar::Util && Scalar::Util::weaken($self->{q[source]});

    # Enforce strict constructor
    my @unknown = grep not( do { package Mite::Miteception; (defined and !ref and m{\A(?:(?:attributes|method_modifiers|name|roles|source))\z}) } ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

    # Call BUILD methods
    unless ( $no_build ) { $_->($self, $args) for @{ $meta->{BUILD} || [] } };

    return $self;
}

defined ${^GLOBAL_PHASE}
    or eval { require Devel::GlobalDestruction; 1 }
    or do   { *Devel::GlobalDestruction::in_global_destruction = sub { undef; } };

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
    require mro;
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

my $__XS = !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

# Accessors for attributes
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[attributes] => q[attributes] },
    );
}
else {
    *attributes = sub { @_ > 1 ? require Carp && Carp::croak("attributes is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[attributes]} };
}

# Accessors for method_modifiers
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[method_modifiers] => q[method_modifiers] },
    );
}
else {
    *method_modifiers = sub { @_ > 1 ? require Carp && Carp::croak("method_modifiers is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[method_modifiers]} };
}

# Accessors for name
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[name] => q[name] },
    );
}
else {
    *name = sub { @_ > 1 ? require Carp && Carp::croak("name is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[name]} };
}

# Accessors for roles
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[roles] => q[roles] },
    );
}
else {
    *roles = sub { @_ > 1 ? require Carp && Carp::croak("roles is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[roles]} };
}

# Accessors for source
*source = sub { @_ > 1 ? do { (do { use Scalar::Util (); Scalar::Util::blessed($_[1]) and $_[1]->isa(q[Mite::Source]) }) or require Carp && Carp::croak(q[Type check failed in accessor: value should be InstanceOf["Mite::Source"]]); $_[0]{q[source]} = $_[1]; require Scalar::Util && Scalar::Util::weaken($_[0]{q[source]}); $_[0]; } : ( $_[0]{q[source]} ) };



1;
}