{

    package Mite::Signature;
    use strict;
    use warnings;

    our $USES_MITE    = "Mite::Class";
    our $MITE_SHIM    = "Mite::Shim";
    our $MITE_VERSION = "0.007006";

    BEGIN {
        require Scalar::Util;
        *bare    = \&Mite::Shim::bare;
        *blessed = \&Scalar::Util::blessed;
        *carp    = \&Mite::Shim::carp;
        *confess = \&Mite::Shim::confess;
        *croak   = \&Mite::Shim::croak;
        *false   = \&Mite::Shim::false;
        *guard   = \&Mite::Shim::guard;
        *lazy    = \&Mite::Shim::lazy;
        *ro      = \&Mite::Shim::ro;
        *rw      = \&Mite::Shim::rw;
        *rwp     = \&Mite::Shim::rwp;
        *true    = \&Mite::Shim::true;
    }

    # Standard Moose/Moo-style constructor
    sub new {
        my $class = ref( $_[0] ) ? ref(shift) : shift;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $self  = bless {}, $class;
        my $args =
            $meta->{HAS_BUILDARGS}
          ? $class->BUILDARGS(@_)
          : { ( @_ == 1 ) ? %{ $_[0] } : @_ };
        my $no_build = delete $args->{__no_BUILD__};

        # Attribute class (type: Mite::Class)
        if ( exists $args->{"class"} ) {
            blessed( $args->{"class"} ) && $args->{"class"}->isa("Mite::Class")
              or croak "Type check failed in constructor: %s should be %s",
              "class", "Mite::Class";
            $self->{"class"} = $args->{"class"};
        }
        require Scalar::Util && Scalar::Util::weaken( $self->{"class"} )
          if ref $self->{"class"};

        # Attribute method_name (type: Str)
        croak "Missing key in constructor: method_name"
          unless exists $args->{"method_name"};
        do {

            package Mite::Shim;
            defined( $args->{"method_name"} ) and do {
                ref( \$args->{"method_name"} ) eq 'SCALAR'
                  or ref( \( my $val = $args->{"method_name"} ) ) eq 'SCALAR';
            }
          }
          or croak "Type check failed in constructor: %s should be %s",
          "method_name", "Str";
        $self->{"method_name"} = $args->{"method_name"};

        # Attribute named (type: ArrayRef)
        if ( exists $args->{"named"} ) {
            do { package Mite::Shim; ref( $args->{"named"} ) eq 'ARRAY' }
              or croak "Type check failed in constructor: %s should be %s",
              "named", "ArrayRef";
            $self->{"named"} = $args->{"named"};
        }

        # Attribute positional (type: ArrayRef)
        my $args_for_positional = {};
        for ( "positional", "pos" ) {
            next unless exists $args->{$_};
            $args_for_positional->{"positional"} = $args->{$_};
            last;
        }
        if ( exists $args_for_positional->{"positional"} ) {
            do {

                package Mite::Shim;
                ref( $args_for_positional->{"positional"} ) eq 'ARRAY';
              }
              or croak "Type check failed in constructor: %s should be %s",
              "positional", "ArrayRef";
            $self->{"positional"} = $args_for_positional->{"positional"};
        }

        # Attribute method (type: Bool)
        do {
            my $value = exists( $args->{"method"} ) ? $args->{"method"} : true;
            (
                !ref $value
                  and (!defined $value
                    or $value eq q()
                    or $value eq '0'
                    or $value eq '1' )
              )
              or croak "Type check failed in constructor: %s should be %s",
              "method", "Bool";
            $self->{"method"} = $value;
        };

        # Attribute head (type: ArrayRef|Int)
        if ( exists $args->{"head"} ) {
            do {

                package Mite::Shim;
                (
                    do { package Mite::Shim; ref( $args->{"head"} ) eq 'ARRAY' }
                      or (
                        do {
                            my $tmp = $args->{"head"};
                            defined($tmp)
                              and !ref($tmp)
                              and $tmp =~ /\A-?[0-9]+\z/;
                        }
                      )
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "head", "ArrayRef|Int";
            $self->{"head"} = $args->{"head"};
        }

        # Attribute tail (type: ArrayRef|Int)
        if ( exists $args->{"tail"} ) {
            do {

                package Mite::Shim;
                (
                    do { package Mite::Shim; ref( $args->{"tail"} ) eq 'ARRAY' }
                      or (
                        do {
                            my $tmp = $args->{"tail"};
                            defined($tmp)
                              and !ref($tmp)
                              and $tmp =~ /\A-?[0-9]+\z/;
                        }
                      )
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "tail", "ArrayRef|Int";
            $self->{"tail"} = $args->{"tail"};
        }

        # Attribute named_to_list (type: Bool|ArrayRef)
        do {
            my $value =
              exists( $args->{"named_to_list"} )
              ? $args->{"named_to_list"}
              : "";
            do {

                package Mite::Shim;
                (
                    (
                        !ref $value
                          and (!defined $value
                            or $value eq q()
                            or $value eq '0'
                            or $value eq '1' )
                    )
                      or ( ref($value) eq 'ARRAY' )
                );
              }
              or croak "Type check failed in constructor: %s should be %s",
              "named_to_list", "Bool|ArrayRef";
            $self->{"named_to_list"} = $value;
        };

        # Call BUILD methods
        $self->BUILDALL($args) if ( !$no_build and @{ $meta->{BUILD} || [] } );

        # Unrecognized parameters
        my @unknown = grep not(
/\A(?:class|head|method(?:_name)?|named(?:_to_list)?|pos(?:itional)?|tail)\z/
        ), keys %{$args};
        @unknown
          and croak(
            "Unexpected keys in constructor: " . join( q[, ], sort @unknown ) );

        return $self;
    }

    # Used by constructor to call BUILD methods
    sub BUILDALL {
        my $class = ref( $_[0] );
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        $_->(@_) for @{ $meta->{BUILD} || [] };
    }

    # Destructor should call DEMOLISH methods
    sub DESTROY {
        my $self  = shift;
        my $class = ref($self) || $self;
        my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
        my $in_global_destruction =
          defined ${^GLOBAL_PHASE}
          ? ${^GLOBAL_PHASE} eq 'DESTRUCT'
          : Devel::GlobalDestruction::in_global_destruction();
        for my $demolisher ( @{ $meta->{DEMOLISH} || [] } ) {
            my $e = do {
                local ( $?, $@ );
                eval { $demolisher->( $self, $in_global_destruction ) };
                $@;
            };
            no warnings 'misc';    # avoid (in cleanup) warnings
            die $e if $e;          # rethrow
        }
        return;
    }

    # Gather metadata for constructor and destructor
    sub __META__ {
        no strict 'refs';
        no warnings 'once';
        my $class = shift;
        $class = ref($class) || $class;
        my $linear_isa = mro::get_linear_isa($class);
        return {
            BUILD => [
                map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
                map { "$_\::BUILD" } reverse @$linear_isa
            ],
            DEMOLISH => [
                map   { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
                  map { "$_\::DEMOLISH" } @$linear_isa
            ],
            HAS_BUILDARGS        => $class->can('BUILDARGS'),
            HAS_FOREIGNBUILDARGS => $class->can('FOREIGNBUILDARGS'),
        };
    }

    # See UNIVERSAL
    sub DOES {
        my ( $self, $role ) = @_;
        our %DOES;
        return $DOES{$role} if exists $DOES{$role};
        return 1            if $role eq __PACKAGE__;
        return $self->SUPER::DOES($role);
    }

    # Alias for Moose/Moo-compatibility
    sub does {
        shift->DOES(@_);
    }

    my $__XS = !$ENV{MITE_PURE_PERL}
      && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

    # Accessors for class
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "class" => "class" },
        );
    }
    else {
        *class = sub {
            @_ > 1
              ? croak("class is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"class"};
        };
    }

    # Accessors for compiler
    sub _assert_blessed_compiler {
        my $object = do {
            (
                exists( $_[0]{"compiler"} ) ? $_[0]{"compiler"} : (
                    $_[0]{"compiler"} = do {
                        my $default_value = $_[0]->_build_compiler;
                        blessed($default_value)
                          or croak(
                            "Type check failed in default: %s should be %s",
                            "compiler", "Object" );
                        $default_value;
                    }
                )
            )
        };
        blessed($object) or croak("compiler is not a blessed object");
        $object;
    }

    sub compiler {
        @_ > 1
          ? croak("compiler is a read-only attribute of @{[ref $_[0]]}")
          : (
            exists( $_[0]{"compiler"} ) ? $_[0]{"compiler"} : (
                $_[0]{"compiler"} = do {
                    my $default_value = $_[0]->_build_compiler;
                    blessed($default_value)
                      or croak( "Type check failed in default: %s should be %s",
                        "compiler", "Object" );
                    $default_value;
                }
            )
          );
    }

    # Delegated methods for compiler
    sub has_head   { shift->_assert_blessed_compiler->has_head(@_) }
    sub has_slurpy { shift->_assert_blessed_compiler->has_slurpy(@_) }
    sub has_tail   { shift->_assert_blessed_compiler->has_tail(@_) }

    # Accessors for compiling_class
    sub compiling_class {
        @_ > 1
          ? do {
            blessed( $_[1] ) && $_[1]->isa("Mite::Role")
              or croak( "Type check failed in %s: value should be %s",
                "accessor", "Mite::Role" );
            $_[0]{"compiling_class"} = $_[1];
            $_[0];
          }
          : ( $_[0]{"compiling_class"} );
    }

    sub locally_set_compiling_class {
        defined wantarray
          or croak("This method cannot be called in void context");
        my $get   = "compiling_class";
        my $set   = "compiling_class";
        my $has   = sub { exists $_[0]{"compiling_class"} };
        my $clear = sub { delete $_[0]{"compiling_class"}; $_[0]; };
        my $old   = undef;
        my ( $self, $new ) = @_;
        my $restorer = $self->$has
          ? do {
            $old = $self->$get;
            sub { $self->$set($old) }
          }
          : sub { $self->$clear };
        @_ == 2 ? $self->$set($new) : $self->$clear;
        &guard( $restorer, $old );
    }

    # Accessors for head
    sub head {
        @_ > 1 ? croak("head is a read-only attribute of @{[ref $_[0]]}") : (
            exists( $_[0]{"head"} ) ? $_[0]{"head"} : (
                $_[0]{"head"} = do {
                    my $default_value = $_[0]->_build_head;
                    do {

                        package Mite::Shim;
                        (
                            ( ref($default_value) eq 'ARRAY' ) or (
                                do {
                                    my $tmp = $default_value;
                                    defined($tmp)
                                      and !ref($tmp)
                                      and $tmp =~ /\A-?[0-9]+\z/;
                                }
                            )
                        );
                      }
                      or croak( "Type check failed in default: %s should be %s",
                        "head", "ArrayRef|Int" );
                    $default_value;
                }
            )
        );
    }

    # Accessors for method
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "method" => "method" },
        );
    }
    else {
        *method = sub {
            @_ > 1
              ? croak("method is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"method"};
        };
    }

    # Accessors for method_name
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "method_name" => "method_name" },
        );
    }
    else {
        *method_name = sub {
            @_ > 1
              ? croak("method_name is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"method_name"};
        };
    }

    # Accessors for named
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "is_named" => "named" },
            "getters"           => { "named"    => "named" },
        );
    }
    else {
        *is_named = sub { exists $_[0]{"named"} };
        *named    = sub {
            @_ > 1
              ? croak("named is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"named"};
        };
    }

    # Accessors for named_to_list
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "named_to_list" => "named_to_list" },
        );
    }
    else {
        *named_to_list = sub {
            @_ > 1
              ? croak(
                "named_to_list is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"named_to_list"};
        };
    }

    # Accessors for positional
    if ($__XS) {
        Class::XSAccessor->import(
            chained             => 1,
            "exists_predicates" => { "is_positional" => "positional" },
            "getters"           => { "positional"    => "positional" },
        );
    }
    else {
        *is_positional = sub { exists $_[0]{"positional"} };
        *positional    = sub {
            @_ > 1
              ? croak("positional is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"positional"};
        };
    }

    # Aliases for for positional
    sub pos { shift->positional(@_) }

    # Accessors for should_bless
    sub should_bless {
        @_ > 1
          ? croak("should_bless is a read-only attribute of @{[ref $_[0]]}")
          : (
            exists( $_[0]{"should_bless"} ) ? $_[0]{"should_bless"} : (
                $_[0]{"should_bless"} = do {
                    my $default_value = $_[0]->_build_should_bless;
                    (
                        !ref $default_value
                          and (!defined $default_value
                            or $default_value eq q()
                            or $default_value eq '0'
                            or $default_value eq '1' )
                      )
                      or croak( "Type check failed in default: %s should be %s",
                        "should_bless", "Bool" );
                    $default_value;
                }
            )
          );
    }

    # Accessors for tail
    if ($__XS) {
        Class::XSAccessor->import(
            chained   => 1,
            "getters" => { "tail" => "tail" },
        );
    }
    else {
        *tail = sub {
            @_ > 1
              ? croak("tail is a read-only attribute of @{[ref $_[0]]}")
              : $_[0]{"tail"};
        };
    }

    1;
}
