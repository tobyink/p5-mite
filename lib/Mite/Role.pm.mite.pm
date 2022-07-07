{
package Mite::Role;
our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "Mite::Shim";
use strict;
use warnings;


sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    if ( exists $args->{"attributes"} ) { (do { package Mite::Miteception; ref($args->{"attributes"}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{"attributes"}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "attributes", "HashRef[InstanceOf[\"Mite::Attribute\"]]" ); $self->{"attributes"} = $args->{"attributes"};  } else { my $value = do { my $default_value = do { my $method = $Mite::Role::__attributes_DEFAULT__; $self->$method }; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Attribute]) }) }; $ok } } or Mite::Shim::croak( "Type check failed in default: %s should be %s", "attributes", "HashRef[InstanceOf[\"Mite::Attribute\"]]" ); $default_value }; $self->{"attributes"} = $value;  };
    if ( exists $args->{"name"} ) { do { package Mite::Miteception; defined($args->{"name"}) and do { ref(\$args->{"name"}) eq 'SCALAR' or ref(\(my $val = $args->{"name"})) eq 'SCALAR' } } or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "name", "Str" ); $self->{"name"} = $args->{"name"};  } else { Mite::Shim::croak( "Missing key in constructor: name" ) };
    if ( exists $args->{"shim_name"} ) { do { package Mite::Miteception; defined($args->{"shim_name"}) and do { ref(\$args->{"shim_name"}) eq 'SCALAR' or ref(\(my $val = $args->{"shim_name"})) eq 'SCALAR' } } or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "shim_name", "Str" ); $self->{"shim_name"} = $args->{"shim_name"};  };
    if ( exists $args->{"source"} ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{"source"}) and $args->{"source"}->isa(q[Mite::Source]) }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "source", "InstanceOf[\"Mite::Source\"]" ); $self->{"source"} = $args->{"source"};  } require Scalar::Util && Scalar::Util::weaken($self->{"source"});
    if ( exists $args->{"roles"} ) { (do { package Mite::Miteception; ref($args->{"roles"}) eq 'ARRAY' } and do { my $ok = 1; for my $i (@{$args->{"roles"}}) { ($ok = 0, last) unless (do { package Mite::Miteception; use Scalar::Util (); Scalar::Util::blessed($i) }) }; $ok }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "roles", "ArrayRef[Object]" ); $self->{"roles"} = $args->{"roles"};  } else { my $value = do { my $default_value = $self->_build_roles; do { package Mite::Miteception; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { package Mite::Miteception; use Scalar::Util (); Scalar::Util::blessed($i) }) }; $ok } } or Mite::Shim::croak( "Type check failed in default: %s should be %s", "roles", "ArrayRef[Object]" ); $default_value }; $self->{"roles"} = $value;  };
    if ( exists $args->{"imported_functions"} ) { (do { package Mite::Miteception; ref($args->{"imported_functions"}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{"imported_functions"}}) { ($ok = 0, last) unless do { package Mite::Miteception; defined($i) and do { ref(\$i) eq 'SCALAR' or ref(\(my $val = $i)) eq 'SCALAR' } } }; $ok }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "imported_functions", "HashRef[Str]" ); $self->{"imported_functions"} = $args->{"imported_functions"};  } else { my $value = do { my $default_value = $self->_build_imported_functions; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless do { package Mite::Miteception; defined($i) and do { ref(\$i) eq 'SCALAR' or ref(\(my $val = $i)) eq 'SCALAR' } } }; $ok } } or Mite::Shim::croak( "Type check failed in default: %s should be %s", "imported_functions", "HashRef[Str]" ); $default_value }; $self->{"imported_functions"} = $value;  };
    if ( exists $args->{"required_methods"} ) { (do { package Mite::Miteception; ref($args->{"required_methods"}) eq 'ARRAY' } and do { my $ok = 1; for my $i (@{$args->{"required_methods"}}) { ($ok = 0, last) unless do { package Mite::Miteception; defined($i) and do { ref(\$i) eq 'SCALAR' or ref(\(my $val = $i)) eq 'SCALAR' } } }; $ok }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "required_methods", "ArrayRef[Str]" ); $self->{"required_methods"} = $args->{"required_methods"};  } else { my $value = do { my $default_value = $self->_build_required_methods; do { package Mite::Miteception; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless do { package Mite::Miteception; defined($i) and do { ref(\$i) eq 'SCALAR' or ref(\(my $val = $i)) eq 'SCALAR' } } }; $ok } } or Mite::Shim::croak( "Type check failed in default: %s should be %s", "required_methods", "ArrayRef[Str]" ); $default_value }; $self->{"required_methods"} = $value;  };

    # Enforce strict constructor
    my @unknown = grep not( /\A(?:attributes|imported_functions|name|r(?:equired_methods|oles)|s(?:him_name|ource))\z/ ), keys %{$args}; @unknown and Mite::Shim::croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    return $self;
}

sub BUILDALL {
    my $class = ref( $_[0] );
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    $_->( @_ ) for @{ $meta->{BUILD} || [] };
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
        HAS_FOREIGNBUILDARGS => $class->can('FOREIGNBUILDARGS'),
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

# Accessors for attributes
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "attributes" => "attributes" },
    );
}
else {
    *attributes = sub { @_ > 1 ? Mite::Shim::croak( "attributes is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"attributes"} };
}

# Accessors for imported_functions
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "imported_functions" => "imported_functions" },
    );
}
else {
    *imported_functions = sub { @_ > 1 ? Mite::Shim::croak( "imported_functions is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"imported_functions"} };
}

# Accessors for name
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "name" => "name" },
    );
}
else {
    *name = sub { @_ > 1 ? Mite::Shim::croak( "name is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"name"} };
}

# Accessors for required_methods
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "required_methods" => "required_methods" },
    );
}
else {
    *required_methods = sub { @_ > 1 ? Mite::Shim::croak( "required_methods is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"required_methods"} };
}

# Accessors for roles
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "roles" => "roles" },
    );
}
else {
    *roles = sub { @_ > 1 ? Mite::Shim::croak( "roles is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"roles"} };
}

# Accessors for shim_name
sub shim_name { @_ > 1 ? do { do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } } or Mite::Shim::croak( "Type check failed in %s: value should be %s", "accessor", "Str" ); $_[0]{"shim_name"} = $_[1]; $_[0]; } : ( $_[0]{"shim_name"} ) }

# Accessors for source
sub source { @_ > 1 ? do { (do { use Scalar::Util (); Scalar::Util::blessed($_[1]) and $_[1]->isa(q[Mite::Source]) }) or Mite::Shim::croak( "Type check failed in %s: value should be %s", "accessor", "InstanceOf[\"Mite::Source\"]" ); $_[0]{"source"} = $_[1]; require Scalar::Util && Scalar::Util::weaken($_[0]{"source"}); $_[0]; } : ( $_[0]{"source"} ) }


1;
}