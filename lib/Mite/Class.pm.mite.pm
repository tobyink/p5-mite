{
package Mite::Class;
use strict;
use warnings;


sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    if ( exists($args->{q[attributes]}) ) { (do { package Mite::Miteception; ref($args->{q[attributes]}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{q[attributes]}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok }) or require Carp && Carp::croak(q[Type check failed in constructor: attributes should be HashRef[InstanceOf["Mite::Attribute"]]]); $self->{q[attributes]} = $args->{q[attributes]};  } else { my $value = do { my $default_value = do { our $__attributes_DEFAULT__; $__attributes_DEFAULT__->($self) }; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: attributes should be HashRef[InstanceOf["Mite::Attribute"]]]) }; $default_value }; $self->{q[attributes]} = $value;  }
    if ( exists($args->{q[extends]}) ) { (do { package Mite::Miteception; ref($args->{q[extends]}) eq 'ARRAY' } and do { my $ok = 1; for my $i (@{$args->{q[extends]}}) { ($ok = 0, last) unless do { package Mite::Miteception; defined($i) and do { ref(\$i) eq 'SCALAR' or ref(\(my $val = $i)) eq 'SCALAR' } } }; $ok }) or require Carp && Carp::croak(q[Type check failed in constructor: extends should be ArrayRef[Str]]); $self->{q[extends]} = $args->{q[extends]};  } else { my $value = do { my $default_value = do { our $__extends_DEFAULT__; $__extends_DEFAULT__->($self) }; do { package Mite::Miteception; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless do { package Mite::Miteception; defined($i) and do { ref(\$i) eq 'SCALAR' or ref(\(my $val = $i)) eq 'SCALAR' } } }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: extends should be ArrayRef[Str]]) }; $default_value }; $self->{q[extends]} = $value;  } $self->_trigger_extends( $self->{q[extends]} );
    if ( exists($args->{q[name]}) ) { do { package Mite::Miteception; defined($args->{q[name]}) and do { ref(\$args->{q[name]}) eq 'SCALAR' or ref(\(my $val = $args->{q[name]})) eq 'SCALAR' } } or require Carp && Carp::croak(q[Type check failed in constructor: name should be Str]); $self->{q[name]} = $args->{q[name]};  } else { require Carp; Carp::croak("Missing key in constructor: name") }
    if ( exists($args->{q[parents]}) ) { (do { package Mite::Miteception; ref($args->{q[parents]}) eq 'ARRAY' } and do { my $ok = 1; for my $i (@{$args->{q[parents]}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Class]) }) }; $ok }) or require Carp && Carp::croak(q[Type check failed in constructor: parents should be ArrayRef[InstanceOf["Mite::Class"]]]); $self->{q[parents]} = $args->{q[parents]};  }
    if ( exists($args->{q[source]}) ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{q[source]}) and $args->{q[source]}->isa(q[Mite::Source]) }) or require Carp && Carp::croak(q[Type check failed in constructor: source should be InstanceOf["Mite::Source"]]); $self->{q[source]} = $args->{q[source]};  }

    # Enforce strict constructor
    my @unknown = grep not( do { package Mite::Miteception; (defined and !ref and m{\A(?:(?:attributes|extends|name|parents|source))\z}) } ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

    # Call BUILD methods
    unless ( $no_build ) { $_->($self, $args) for @{ $meta->{BUILD} || [] } };

    return $self;
}

defined ${^GLOBAL_PHASE}
    or eval { require Devel::GlobalDestruction; 1 }
    or do   { *Devel::GlobalDestruction::in_global_destruction = sub { undef; } };

sub DESTROY {
    my $self = shift;
    my $class = ref( $self ) || $self;
    my $meta = ( $Mite::META{$class} ||= $class->__META__ );
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
    my $class = shift; $class = ref($class) || $class;
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

# Accessors for extends
*superclasses = sub { @_ > 1 ? do { my @oldvalue; @oldvalue = $_[0]{q[extends]} if exists $_[0]{q[extends]}; do { package Mite::Miteception; (ref($_[1]) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$_[1]}) { ($ok = 0, last) unless do { package Mite::Miteception; defined($i) and do { ref(\$i) eq 'SCALAR' or ref(\(my $val = $i)) eq 'SCALAR' } } }; $ok } } or require Carp && Carp::croak(q[Type check failed in accessor: value should be ArrayRef[Str]]); $_[0]{q[extends]} = $_[1]; $_[0]->_trigger_extends( $_[0]{q[extends]}, @oldvalue ); $_[0]; } : ( $_[0]{q[extends]} ) };

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

# Accessors for parents
*_clear_parents = sub { delete $_[0]->{q[parents]}; $_[0]; };
*parents = sub { @_ > 1 ? require Carp && Carp::croak("parents is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[parents]}) ? $_[0]{q[parents]} : ( $_[0]{q[parents]} = do { my $default_value = $_[0]->_build_parents; do { package Mite::Miteception; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Class]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: parents should be ArrayRef[InstanceOf["Mite::Class"]]]) }; $default_value } ) ) };

# Accessors for source
*source = sub { @_ > 1 ? do { (do { use Scalar::Util (); Scalar::Util::blessed($_[1]) and $_[1]->isa(q[Mite::Source]) }) or require Carp && Carp::croak(q[Type check failed in accessor: value should be InstanceOf["Mite::Source"]]); $_[0]{q[source]} = $_[1]; $_[0]; } : ( $_[0]{q[source]} ) };


1;
}