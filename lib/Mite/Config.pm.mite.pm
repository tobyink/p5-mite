{
package Mite::Config;
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
    if ( exists $args->{"mite_dir_name"} ) { do { package Mite::Miteception; defined($args->{"mite_dir_name"}) and do { ref(\$args->{"mite_dir_name"}) eq 'SCALAR' or ref(\(my $val = $args->{"mite_dir_name"})) eq 'SCALAR' } } or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "mite_dir_name", "Str" ); $self->{"mite_dir_name"} = $args->{"mite_dir_name"};  } else { my $value = do { my $default_value = ".mite"; do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } } or Mite::Shim::croak( "Type check failed in default: %s should be %s", "mite_dir_name", "Str" ); $default_value }; $self->{"mite_dir_name"} = $value;  };
    if ( exists $args->{"mite_dir"} ) { my $value = do { my $to_coerce = $args->{"mite_dir"}; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($value) and $value->isa(q[Path::Tiny]) }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "mite_dir", "Path" ); $self->{"mite_dir"} = $value;  };
    if ( exists $args->{"config_file"} ) { my $value = do { my $to_coerce = $args->{"config_file"}; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($value) and $value->isa(q[Path::Tiny]) }) or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "config_file", "Path" ); $self->{"config_file"} = $value;  };
    if ( exists $args->{"data"} ) { do { package Mite::Miteception; ref($args->{"data"}) eq 'HASH' } or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "data", "HashRef" ); $self->{"data"} = $args->{"data"};  };
    if ( exists $args->{"search_for_mite_dir"} ) { do { package Mite::Miteception; !ref $args->{"search_for_mite_dir"} and (!defined $args->{"search_for_mite_dir"} or $args->{"search_for_mite_dir"} eq q() or $args->{"search_for_mite_dir"} eq '0' or $args->{"search_for_mite_dir"} eq '1') } or Mite::Shim::croak( "Type check failed in constructor: %s should be %s", "search_for_mite_dir", "Bool" ); $self->{"search_for_mite_dir"} = $args->{"search_for_mite_dir"};  } else { my $value = do { my $default_value = "1"; (!ref $default_value and (!defined $default_value or $default_value eq q() or $default_value eq '0' or $default_value eq '1')) or Mite::Shim::croak( "Type check failed in default: %s should be %s", "search_for_mite_dir", "Bool" ); $default_value }; $self->{"search_for_mite_dir"} = $value;  };

    # Enforce strict constructor
    my @unknown = grep not( /\A(?:config_file|data|mite_dir(?:_name)?|search_for_mite_dir)\z/ ), keys %{$args}; @unknown and Mite::Shim::croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

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

# Accessors for config_file
sub config_file { @_ > 1 ? Mite::Shim::croak( "config_file is a read-only attribute of @{[ref $_[0]]}" ) : ( exists($_[0]{"config_file"}) ? $_[0]{"config_file"} : ( $_[0]{"config_file"} = do { my $default_value = do { my $to_coerce = do { my $method = $Mite::Config::__config_file_DEFAULT__; $_[0]->$method }; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($default_value) and $default_value->isa(q[Path::Tiny]) }) or Mite::Shim::croak( "Type check failed in default: %s should be %s", "config_file", "Path" ); $default_value } ) ) }

# Accessors for data
sub data { @_ > 1 ? do { (ref($_[1]) eq 'HASH') or Mite::Shim::croak( "Type check failed in %s: value should be %s", "accessor", "HashRef" ); $_[0]{"data"} = $_[1]; $_[0]; } : do { ( exists($_[0]{"data"}) ? $_[0]{"data"} : ( $_[0]{"data"} = do { my $default_value = do { my $method = $Mite::Config::__data_DEFAULT__; $_[0]->$method }; (ref($default_value) eq 'HASH') or Mite::Shim::croak( "Type check failed in default: %s should be %s", "data", "HashRef" ); $default_value } ) ) } }

# Accessors for mite_dir
sub mite_dir { @_ > 1 ? Mite::Shim::croak( "mite_dir is a read-only attribute of @{[ref $_[0]]}" ) : ( exists($_[0]{"mite_dir"}) ? $_[0]{"mite_dir"} : ( $_[0]{"mite_dir"} = do { my $default_value = do { my $to_coerce = do { my $method = $Mite::Config::__mite_dir_DEFAULT__; $_[0]->$method }; ((do { use Scalar::Util (); Scalar::Util::blessed($to_coerce) and $to_coerce->isa(q[Path::Tiny]) })) ? $to_coerce : (do { package Mite::Miteception; defined($to_coerce) and do { ref(\$to_coerce) eq 'SCALAR' or ref(\(my $val = $to_coerce)) eq 'SCALAR' } }) ? scalar(do { local $_ = $to_coerce; Path::Tiny::path($_) }) : $to_coerce }; (do { use Scalar::Util (); Scalar::Util::blessed($default_value) and $default_value->isa(q[Path::Tiny]) }) or Mite::Shim::croak( "Type check failed in default: %s should be %s", "mite_dir", "Path" ); $default_value } ) ) }

# Accessors for mite_dir_name
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "mite_dir_name" => "mite_dir_name" },
    );
}
else {
    *mite_dir_name = sub { @_ > 1 ? Mite::Shim::croak( "mite_dir_name is a read-only attribute of @{[ref $_[0]]}" ) : $_[0]{"mite_dir_name"} };
}

# Accessors for search_for_mite_dir
sub search_for_mite_dir { @_ > 1 ? do { (!ref $_[1] and (!defined $_[1] or $_[1] eq q() or $_[1] eq '0' or $_[1] eq '1')) or Mite::Shim::croak( "Type check failed in %s: value should be %s", "accessor", "Bool" ); $_[0]{"search_for_mite_dir"} = $_[1]; $_[0]; } : ( $_[0]{"search_for_mite_dir"} ) }


1;
}