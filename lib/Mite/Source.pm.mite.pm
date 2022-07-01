{
package Mite::Source;
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
    if ( exists($args->{q[classes]}) ) { (do { package Mite::Miteception; ref($args->{q[classes]}) eq 'HASH' } and do { my $ok = 1; for my $i (values %{$args->{q[classes]}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Class]) }) }; $ok }) or require Carp && Carp::croak(q[Type check failed in constructor: classes should be HashRef[InstanceOf["Mite::Class"]]]); $self->{q[classes]} = $args->{q[classes]};  } else { my $value = do { my $default_value = do { my $method = $Mite::Source::__classes_DEFAULT__; $self->$method }; do { package Mite::Miteception; (ref($default_value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Mite::Class]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: classes should be HashRef[InstanceOf["Mite::Class"]]]) }; $default_value }; $self->{q[classes]} = $value;  }
    if ( exists($args->{q[compiled]}) ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{q[compiled]}) and $args->{q[compiled]}->isa(q[Mite::Compiled]) }) or require Carp && Carp::croak(q[Type check failed in constructor: compiled should be InstanceOf["Mite::Compiled"]]); $self->{q[compiled]} = $args->{q[compiled]};  }
    if ( exists($args->{q[file]}) ) { my $value = do { my $to_coerce = $args->{q[file]}; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($value) and $value->isa(q[Path::Tiny]) }) or require Carp && Carp::croak(q[Type check failed in constructor: file should be Path]); $self->{q[file]} = $value;  } else { require Carp; Carp::croak("Missing key in constructor: file") }
    if ( exists($args->{q[project]}) ) { (do { use Scalar::Util (); Scalar::Util::blessed($args->{q[project]}) and $args->{q[project]}->isa(q[Mite::Project]) }) or require Carp && Carp::croak(q[Type check failed in constructor: project should be InstanceOf["Mite::Project"]]); $self->{q[project]} = $args->{q[project]};  } require Scalar::Util && Scalar::Util::weaken($self->{q[project]});

    # Enforce strict constructor
    my @unknown = grep not( do { package Mite::Miteception; (defined and !ref and m{\A(?:(?:c(?:lasses|ompiled)|file|project))\z}) } ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

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

# Accessors for classes
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[classes] => q[classes] },
    );
}
else {
    *classes = sub { @_ > 1 ? require Carp && Carp::croak("classes is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[classes]} };
}

# Accessors for compiled
*compiled = sub { @_ > 1 ? require Carp && Carp::croak("compiled is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[compiled]}) ? $_[0]{q[compiled]} : ( $_[0]{q[compiled]} = do { my $default_value = do { my $method = $Mite::Source::__compiled_DEFAULT__; $_[0]->$method }; (do { use Scalar::Util (); Scalar::Util::blessed($default_value) and $default_value->isa(q[Mite::Compiled]) }) or do { require Carp; Carp::croak(q[Type check failed in default: compiled should be InstanceOf["Mite::Compiled"]]) }; $default_value } ) ) };

# Accessors for file
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[file] => q[file] },
    );
}
else {
    *file = sub { @_ > 1 ? require Carp && Carp::croak("file is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[file]} };
}

# Accessors for project
*project = sub { @_ > 1 ? do { (do { use Scalar::Util (); Scalar::Util::blessed($_[1]) and $_[1]->isa(q[Mite::Project]) }) or require Carp && Carp::croak(q[Type check failed in accessor: value should be InstanceOf["Mite::Project"]]); $_[0]{q[project]} = $_[1]; require Scalar::Util && Scalar::Util::weaken($_[0]{q[project]}); $_[0]; } : ( $_[0]{q[project]} ) };



1;
}