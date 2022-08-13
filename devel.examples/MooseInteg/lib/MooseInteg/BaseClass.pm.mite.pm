{
package MooseInteg::BaseClass;
use strict;
use warnings;
no warnings qw( once void );

our $USES_MITE = "Mite::Class";
our $MITE_SHIM = "MooseInteg::Mite";
our $MITE_VERSION = "0.010003";
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( "MooseInteg::Mite", "MooseInteg::BaseClass" );
    ( *after, *around, *before, *extends, *has, *signature_for, *with ) = do {
        package MooseInteg::Mite;
        no warnings 'redefine';
        (
            sub { $SHIM->HANDLE_after( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_around( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_before( $CALLER, "class", @_ ) },
            sub {},
            sub { $SHIM->HANDLE_has( $CALLER, has => @_ ) },
            sub { $SHIM->HANDLE_signature_for( $CALLER, "class", @_ ) },
            sub { $SHIM->HANDLE_with( $CALLER, @_ ) },
        );
    };
};

# Gather metadata for constructor and destructor
sub __META__ {
    no strict 'refs';
    no warnings 'once';
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

# Moose-compatibility method
sub meta {
    require MooseInteg::MOP;
    Moose::Util::find_meta( ref $_[0] or $_[0] );
}


# Standard Moose/Moo-style constructor
sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Attribute foo (type: Int)
    # has declaration, file lib/MooseInteg/BaseClass.pm, line 5
    if ( exists $args->{"foo"} ) { (do { my $tmp = $args->{"foo"}; defined($tmp) and !ref($tmp) and $tmp =~ /\A-?[0-9]+\z/ }) or MooseInteg::Mite::croak "Type check failed in constructor: %s should be %s", "foo", "Int"; $self->{"foo"} = $args->{"foo"}; } ;

    # Attribute hashy (type: HashRef[Int])
    # has declaration, file lib/MooseInteg/BaseClass.pm, line 10
    do { my $value = exists( $args->{"hashy"} ) ? $args->{"hashy"} : {}; do { package MooseInteg::Mite; (ref($value) eq 'HASH') and do { my $ok = 1; for my $i (values %{$value}) { ($ok = 0, last) unless (do { my $tmp = $i; defined($tmp) and !ref($tmp) and $tmp =~ /\A-?[0-9]+\z/ }) }; $ok } } or MooseInteg::Mite::croak "Type check failed in constructor: %s should be %s", "hashy", "HashRef[Int]"; $self->{"hashy"} = $value; }; 


    # Call BUILD methods
    $self->BUILDALL( $args ) if ( ! $no_build and @{ $meta->{BUILD} || [] } );

    # Unrecognized parameters
    my @unknown = grep not( /\A(?:foo|hashy)\z/ ), keys %{$args}; @unknown and MooseInteg::Mite::croak( "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

    return $self;
}

# Used by constructor to call BUILD methods
sub BUILDALL {
    my $class = ref( $_[0] );
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    $_->( @_ ) for @{ $meta->{BUILD} || [] };
}

# Destructor should call DEMOLISH methods
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

my $__XS = !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

# Accessors for foo
# has declaration, file lib/MooseInteg/BaseClass.pm, line 5
sub foo { @_ > 1 ? do { (do { my $tmp = $_[1]; defined($tmp) and !ref($tmp) and $tmp =~ /\A-?[0-9]+\z/ }) or MooseInteg::Mite::croak( "Type check failed in %s: value should be %s", "accessor", "Int" ); $_[0]{"foo"} = $_[1]; $_[0]; } : ( $_[0]{"foo"} ) }

# Accessors for hashy
# has declaration, file lib/MooseInteg/BaseClass.pm, line 10
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        "getters" => { "hashy" => "hashy" },
    );
}
else {
    *hashy = sub { @_ == 1 or MooseInteg::Mite::croak( 'Reader "hashy" usage: $self->hashy()' ); $_[0]{"hashy"} };
}

# Delegated methods for hashy
# has declaration, file lib/MooseInteg/BaseClass.pm, line 10
*hashy_set = sub {
@_ >= 3 or MooseInteg::Mite::croak("Wrong number of parameters in signature for hashy_set; usage: "."\$instance->hashy_set(\$key, \$value, ...)");
my $shv_self=shift;
my $shv_ref_invocant = do { $shv_self->hashy };
my (@shv_params) = @_; scalar(@shv_params) % 2 and do { require Carp; Carp::croak("Wrong number of parameters; expected even-sized list of keys and values") };my (@shv_keys_idx) = grep(!($_ % 2), 0..$#shv_params); my (@shv_values_idx) = grep(($_ % 2), 0..$#shv_params); grep(!defined, @shv_params[@shv_keys_idx]) and do { require Carp; Carp::croak("Undef did not pass type constraint; keys must be defined") };for my $shv_tmp (@shv_keys_idx) { do { do { package MooseInteg::Mite; defined($shv_params[$shv_tmp]) and do { ref(\$shv_params[$shv_tmp]) eq 'SCALAR' or ref(\(my $val = $shv_params[$shv_tmp])) eq 'SCALAR' } } or MooseInteg::Mite::croak("Type check failed in delegated method: expected %s, got value %s", "Str", $shv_params[$shv_tmp]); $shv_params[$shv_tmp] }; }; for my $shv_tmp (@shv_values_idx) { do { (do { my $tmp = $shv_params[$shv_tmp]; defined($tmp) and !ref($tmp) and $tmp =~ /\A-?[0-9]+\z/ }) or MooseInteg::Mite::croak("Type check failed in delegated method: expected %s, got value %s", "Int", $shv_params[$shv_tmp]); $shv_params[$shv_tmp] }; };; @{$shv_ref_invocant}{@shv_params[@shv_keys_idx]} = @shv_params[@shv_values_idx];wantarray ? @{$shv_ref_invocant}{@shv_params[@shv_keys_idx]} : ($shv_ref_invocant)->{$shv_params[$shv_keys_idx[0]]}
};

# See UNIVERSAL
sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    return $self->SUPER::DOES( $role );
}

# Alias for Moose/Moo-compatibility
sub does {
    shift->DOES( @_ );
}

1;
}