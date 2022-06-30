{
package Mite::Config;
our $USES_MITE = 1;
use strict;
use warnings;


sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    if ( exists($args->{q[config_file]}) ) { my $value = do { my $to_coerce = $args->{q[config_file]}; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($value) and $value->isa(q[Path::Tiny]) }) or require Carp && Carp::croak(q[Type check failed in constructor: config_file should be Path]); $self->{q[config_file]} = $value;  }
    if ( exists($args->{q[data]}) ) { do { package Mite::Miteception; ref($args->{q[data]}) eq 'HASH' } or require Carp && Carp::croak(q[Type check failed in constructor: data should be HashRef]); $self->{q[data]} = $args->{q[data]};  }
    if ( exists($args->{q[mite_dir]}) ) { my $value = do { my $to_coerce = $args->{q[mite_dir]}; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($value) and $value->isa(q[Path::Tiny]) }) or require Carp && Carp::croak(q[Type check failed in constructor: mite_dir should be Path]); $self->{q[mite_dir]} = $value;  }
    if ( exists($args->{q[mite_dir_name]}) ) { do { package Mite::Miteception; defined($args->{q[mite_dir_name]}) and do { ref(\$args->{q[mite_dir_name]}) eq 'SCALAR' or ref(\(my $val = $args->{q[mite_dir_name]})) eq 'SCALAR' } } or require Carp && Carp::croak(q[Type check failed in constructor: mite_dir_name should be Str]); $self->{q[mite_dir_name]} = $args->{q[mite_dir_name]};  } else { my $value = do { my $default_value = ".mite"; do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } } or do { require Carp; Carp::croak(q[Type check failed in default: mite_dir_name should be Str]) }; $default_value }; $self->{q[mite_dir_name]} = $value;  }
    if ( exists($args->{q[search_for_mite_dir]}) ) { do { package Mite::Miteception; !ref $args->{q[search_for_mite_dir]} and (!defined $args->{q[search_for_mite_dir]} or $args->{q[search_for_mite_dir]} eq q() or $args->{q[search_for_mite_dir]} eq '0' or $args->{q[search_for_mite_dir]} eq '1') } or require Carp && Carp::croak(q[Type check failed in constructor: search_for_mite_dir should be Bool]); $self->{q[search_for_mite_dir]} = $args->{q[search_for_mite_dir]};  } else { my $value = do { my $default_value = "1"; (!ref $default_value and (!defined $default_value or $default_value eq q() or $default_value eq '0' or $default_value eq '1')) or do { require Carp; Carp::croak(q[Type check failed in default: search_for_mite_dir should be Bool]) }; $default_value }; $self->{q[search_for_mite_dir]} = $value;  }

    # Enforce strict constructor
    my @unknown = grep not( do { package Mite::Miteception; (defined and !ref and m{\A(?:(?:config_file|data|mite_dir(?:_name)?|search_for_mite_dir))\z}) } ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

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

# Accessors for config_file
*config_file = sub { @_ > 1 ? require Carp && Carp::croak("config_file is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[config_file]}) ? $_[0]{q[config_file]} : ( $_[0]{q[config_file]} = do { my $default_value = do { my $to_coerce = do { our $__config_file_DEFAULT__; $__config_file_DEFAULT__->($_[0]) }; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($default_value) and $default_value->isa(q[Path::Tiny]) }) or do { require Carp; Carp::croak(q[Type check failed in default: config_file should be Path]) }; $default_value } ) ) };

# Accessors for data
*data = sub { @_ > 1 ? do { (ref($_[1]) eq 'HASH') or require Carp && Carp::croak(q[Type check failed in accessor: value should be HashRef]); $_[0]{q[data]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[data]}) ? $_[0]{q[data]} : ( $_[0]{q[data]} = do { my $default_value = do { our $__data_DEFAULT__; $__data_DEFAULT__->($_[0]) }; (ref($default_value) eq 'HASH') or do { require Carp; Carp::croak(q[Type check failed in default: data should be HashRef]) }; $default_value } ) ) } };

# Accessors for mite_dir
*mite_dir = sub { @_ > 1 ? require Carp && Carp::croak("mite_dir is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[mite_dir]}) ? $_[0]{q[mite_dir]} : ( $_[0]{q[mite_dir]} = do { my $default_value = do { my $to_coerce = do { our $__mite_dir_DEFAULT__; $__mite_dir_DEFAULT__->($_[0]) }; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($default_value) and $default_value->isa(q[Path::Tiny]) }) or do { require Carp; Carp::croak(q[Type check failed in default: mite_dir should be Path]) }; $default_value } ) ) };

# Accessors for mite_dir_name
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[mite_dir_name] => q[mite_dir_name] },
    );
}
else {
    *mite_dir_name = sub { @_ > 1 ? require Carp && Carp::croak("mite_dir_name is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[mite_dir_name]} };
}

# Accessors for search_for_mite_dir
*search_for_mite_dir = sub { @_ > 1 ? do { (!ref $_[1] and (!defined $_[1] or $_[1] eq q() or $_[1] eq '0' or $_[1] eq '1')) or require Carp && Carp::croak(q[Type check failed in accessor: value should be Bool]); $_[0]{q[search_for_mite_dir]} = $_[1]; $_[0]; } : ( $_[0]{q[search_for_mite_dir]} ) };


1;
}