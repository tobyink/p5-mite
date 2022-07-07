{
package Mite::Source;
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
    if ( exists $args->{"file"} ) { my $value = do { my $to_coerce = $args->{"file"}; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($value) and $value->isa(q[Path::Tiny]) }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "file", "Path" ); $self->{"file"} = $value;  } else { Mite::Shim::croak( "Missing key in constructor: file" ) };
    if ( exists $args->{"classes"} ) { (do { package Mite::Miteception; ref($args->{"classes"}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{"classes"}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Class]) }) }; $ok }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "classes", "HashRef[InstanceOf[\"Mite::Class\"]]" ); $self->{"classes"} = $args->{"classes"};  } else { my $value = do { my $default_value = do { my $method = $Mite::Source::__classes_DEFAULT__; $self->$method }; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Class]) }) }; $ok } } or Mite::Shim::croak( "Type check failed in default: %s should be %s", "classes", "HashRef[InstanceOf[\"Mite::Class\"]]" ); $default_value }; $self->{"classes"} = $value;  };
    if ( exists $args->{"compiled"} ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{"compiled"}) and $args->{"compiled"}->isa(q[Mite::Compiled]) }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "compiled", "InstanceOf[\"Mite::Compiled\"]" ); $self->{"compiled"} = $args->{"compiled"};  };
    if ( exists $args->{"project"} ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{"project"}) and $args->{"project"}->isa(q[Mite::Project]) }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "project", "InstanceOf[\"Mite::Project\"]" ); $self->{"project"} = $args->{"project"};  } require Scalar::Util && Scalar::Util::weaken($self->{"project"});

    # Enforce strict constructor
    my @unknown = grep not( /\A(?:c(?:lasses|ompiled)|file|project)\z/ ), keys %{$args}; @unknown and Mite::Shim::croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

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

# Accessors for classes
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "classes" => "classes" },
    );
}
else {
    *classes = sub { @_ > 1 ? Mite::Shim::croak( "classes is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"classes"} };
}

# Accessors for compiled
sub compiled { @_ > 1 ? Mite::Shim::croak( "compiled is a read-only attribute of @{[ref $_[0]]}" ) : ( exists($_[0]{"compiled"}) ? $_[0]{"compiled"} : ( $_[0]{"compiled"} = do { my $default_value = do { my $method = $Mite::Source::__compiled_DEFAULT__; $_[0]->$method }; (do { use Scalar::Util (); Scalar::Util::blessed($default_value) and $default_value->isa(q[Mite::Compiled]) }) or Mite::Shim::croak( "Type check failed in default: %s should be %s", "compiled", "InstanceOf[\"Mite::Compiled\"]" ); $default_value } ) ) }

# Accessors for file
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "file" => "file" },
    );
}
else {
    *file = sub { @_ > 1 ? Mite::Shim::croak( "file is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"file"} };
}

# Accessors for project
sub project { @_ > 1 ? do { (do { use Scalar::Util (); Scalar::Util::blessed($_[1]) and $_[1]->isa(q[Mite::Project]) }) or Mite::Shim::croak( "Type check failed in %s: value should be %s", "accessor", "InstanceOf[\"Mite::Project\"]" ); $_[0]{"project"} = $_[1]; require Scalar::Util && Scalar::Util::weaken($_[0]{"project"}); $_[0]; } : ( $_[0]{"project"} ) }


1;
}