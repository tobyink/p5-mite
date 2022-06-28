{
package Mite::Attribute;
use strict;
use warnings;


sub new {
    my $class = shift;
    my $meta  = ( $Mite::META{$class} ||= $class->__META__ );
    my $self  = bless {}, $class;
    my $args  = $meta->{HAS_BUILDARGS} ? $class->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %{$_[0]} : @_ };
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    if ( exists($args->{q[accessor]}) ) { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($args->{q[accessor]}) and do { ref(\$args->{q[accessor]}) eq 'SCALAR' or ref(\(my $val = $args->{q[accessor]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[accessor]}; length($_) > 0 })) or do { package Mite::Miteception; !defined($args->{q[accessor]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: accessor should be __ANON__|Undef]); $self->{q[accessor]} = $args->{q[accessor]};  }
    if ( exists($args->{q[builder]}) ) { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($args->{q[builder]}) and do { ref(\$args->{q[builder]}) eq 'SCALAR' or ref(\(my $val = $args->{q[builder]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[builder]}; length($_) > 0 })) or do { package Mite::Miteception; ref($args->{q[builder]}) eq 'CODE' } or do { package Mite::Miteception; !defined($args->{q[builder]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: builder should be __ANON__|CodeRef|Undef]); $self->{q[builder]} = $args->{q[builder]};  }
    if ( exists($args->{q[class]}) ) { (do { package Mite::Miteception; use Scalar::Util (); Scalar::Util::blessed($args->{q[class]}) }) or require Carp && Carp::croak(q[Type check failed in constructor: class should be Object]); $self->{q[class]} = $args->{q[class]};  } require Scalar::Util && Scalar::Util::weaken($self->{q[class]});
    if ( exists($args->{q[clearer]}) ) { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($args->{q[clearer]}) and do { ref(\$args->{q[clearer]}) eq 'SCALAR' or ref(\(my $val = $args->{q[clearer]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[clearer]}; length($_) > 0 })) or do { package Mite::Miteception; !defined($args->{q[clearer]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: clearer should be __ANON__|Undef]); $self->{q[clearer]} = $args->{q[clearer]};  }
    if ( exists($args->{q[coderef_default_variable]}) ) { do { package Mite::Miteception; defined($args->{q[coderef_default_variable]}) and do { ref(\$args->{q[coderef_default_variable]}) eq 'SCALAR' or ref(\(my $val = $args->{q[coderef_default_variable]})) eq 'SCALAR' } } or require Carp && Carp::croak(q[Type check failed in constructor: coderef_default_variable should be Str]); $self->{q[coderef_default_variable]} = $args->{q[coderef_default_variable]};  }
    if ( exists($args->{q[coerce]}) ) { do { package Mite::Miteception; !ref $args->{q[coerce]} and (!defined $args->{q[coerce]} or $args->{q[coerce]} eq q() or $args->{q[coerce]} eq '0' or $args->{q[coerce]} eq '1') } or require Carp && Carp::croak(q[Type check failed in constructor: coerce should be Bool]); $self->{q[coerce]} = $args->{q[coerce]};  } else { my $value = do { my $default_value = ""; (!ref $default_value and (!defined $default_value or $default_value eq q() or $default_value eq '0' or $default_value eq '1')) or do { require Carp; Carp::croak(q[Type check failed in default: coerce should be Bool]) }; $default_value }; $self->{q[coerce]} = $value;  }
    if ( exists($args->{q[default]}) ) { do { package Mite::Miteception; !defined($args->{q[default]}) or do { package Mite::Miteception; (do { package Mite::Miteception; defined($args->{q[default]}) and do { ref(\$args->{q[default]}) eq 'SCALAR' or ref(\(my $val = $args->{q[default]})) eq 'SCALAR' } } or do { package Mite::Miteception; !!ref($args->{q[default]}) }) } } or require Carp && Carp::croak(q[Type check failed in constructor: default should be Maybe[Str|Ref]]); $self->{q[default]} = $args->{q[default]};  }
    if ( exists($args->{q[documentation]}) ) { $self->{q[documentation]} = $args->{q[documentation]};  }
    if ( exists($args->{q[init_arg]}) ) { do { package Mite::Miteception; (do { package Mite::Miteception; defined($args->{q[init_arg]}) and do { ref(\$args->{q[init_arg]}) eq 'SCALAR' or ref(\(my $val = $args->{q[init_arg]})) eq 'SCALAR' } } or do { package Mite::Miteception; !defined($args->{q[init_arg]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: init_arg should be Str|Undef]); $self->{q[init_arg]} = $args->{q[init_arg]};  }
    if ( exists($args->{q[is]}) ) { do { package Mite::Miteception; (defined($args->{q[is]}) and !ref($args->{q[is]}) and $args->{q[is]} =~ m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z}) } or require Carp && Carp::croak(q[Type check failed in constructor: is should be Enum["ro","rw","rwp","lazy","bare"]]); $self->{q[is]} = $args->{q[is]};  } else { my $value = do { my $default_value = "bare"; do { package Mite::Miteception; (defined($default_value) and !ref($default_value) and $default_value =~ m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z}) } or do { require Carp; Carp::croak(q[Type check failed in default: is should be Enum["ro","rw","rwp","lazy","bare"]]) }; $default_value }; $self->{q[is]} = $value;  }
    if ( exists($args->{q[isa]}) ) { do { package Mite::Miteception; (do { package Mite::Miteception; defined($args->{q[isa]}) and do { ref(\$args->{q[isa]}) eq 'SCALAR' or ref(\(my $val = $args->{q[isa]})) eq 'SCALAR' } } or (do { package Mite::Miteception; use Scalar::Util (); Scalar::Util::blessed($args->{q[isa]}) })) } or require Carp && Carp::croak(q[Type check failed in constructor: isa should be Str|Object]); $self->{q[isa]} = $args->{q[isa]};  }
    if ( exists($args->{q[lazy]}) ) { do { package Mite::Miteception; !ref $args->{q[lazy]} and (!defined $args->{q[lazy]} or $args->{q[lazy]} eq q() or $args->{q[lazy]} eq '0' or $args->{q[lazy]} eq '1') } or require Carp && Carp::croak(q[Type check failed in constructor: lazy should be Bool]); $self->{q[lazy]} = $args->{q[lazy]};  } else { my $value = do { my $default_value = ""; (!ref $default_value and (!defined $default_value or $default_value eq q() or $default_value eq '0' or $default_value eq '1')) or do { require Carp; Carp::croak(q[Type check failed in default: lazy should be Bool]) }; $default_value }; $self->{q[lazy]} = $value;  }
    if ( exists($args->{q[name]}) ) { ((do { package Mite::Miteception; defined($args->{q[name]}) and do { ref(\$args->{q[name]}) eq 'SCALAR' or ref(\(my $val = $args->{q[name]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[name]}; length($_) > 0 })) or require Carp && Carp::croak(q[Type check failed in constructor: name should be __ANON__]); $self->{q[name]} = $args->{q[name]};  } else { require Carp; Carp::croak("Missing key in constructor: name") }
    if ( exists($args->{q[predicate]}) ) { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($args->{q[predicate]}) and do { ref(\$args->{q[predicate]}) eq 'SCALAR' or ref(\(my $val = $args->{q[predicate]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[predicate]}; length($_) > 0 })) or do { package Mite::Miteception; !defined($args->{q[predicate]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: predicate should be __ANON__|Undef]); $self->{q[predicate]} = $args->{q[predicate]};  }
    if ( exists($args->{q[reader]}) ) { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($args->{q[reader]}) and do { ref(\$args->{q[reader]}) eq 'SCALAR' or ref(\(my $val = $args->{q[reader]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[reader]}; length($_) > 0 })) or do { package Mite::Miteception; !defined($args->{q[reader]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: reader should be __ANON__|Undef]); $self->{q[reader]} = $args->{q[reader]};  }
    if ( exists($args->{q[required]}) ) { do { package Mite::Miteception; !ref $args->{q[required]} and (!defined $args->{q[required]} or $args->{q[required]} eq q() or $args->{q[required]} eq '0' or $args->{q[required]} eq '1') } or require Carp && Carp::croak(q[Type check failed in constructor: required should be Bool]); $self->{q[required]} = $args->{q[required]};  } else { my $value = do { my $default_value = ""; (!ref $default_value and (!defined $default_value or $default_value eq q() or $default_value eq '0' or $default_value eq '1')) or do { require Carp; Carp::croak(q[Type check failed in default: required should be Bool]) }; $default_value }; $self->{q[required]} = $value;  }
    if ( exists($args->{q[trigger]}) ) { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($args->{q[trigger]}) and do { ref(\$args->{q[trigger]}) eq 'SCALAR' or ref(\(my $val = $args->{q[trigger]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[trigger]}; length($_) > 0 })) or do { package Mite::Miteception; ref($args->{q[trigger]}) eq 'CODE' } or do { package Mite::Miteception; !defined($args->{q[trigger]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: trigger should be __ANON__|CodeRef|Undef]); $self->{q[trigger]} = $args->{q[trigger]};  }
    if ( exists($args->{q[type]}) ) { do { package Mite::Miteception; ((do { package Mite::Miteception; use Scalar::Util (); Scalar::Util::blessed($args->{q[type]}) }) or do { package Mite::Miteception; !defined($args->{q[type]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: type should be Object|Undef]); $self->{q[type]} = $args->{q[type]};  }
    if ( exists($args->{q[weak_ref]}) ) { do { package Mite::Miteception; !ref $args->{q[weak_ref]} and (!defined $args->{q[weak_ref]} or $args->{q[weak_ref]} eq q() or $args->{q[weak_ref]} eq '0' or $args->{q[weak_ref]} eq '1') } or require Carp && Carp::croak(q[Type check failed in constructor: weak_ref should be Bool]); $self->{q[weak_ref]} = $args->{q[weak_ref]};  } else { my $value = do { my $default_value = ""; (!ref $default_value and (!defined $default_value or $default_value eq q() or $default_value eq '0' or $default_value eq '1')) or do { require Carp; Carp::croak(q[Type check failed in default: weak_ref should be Bool]) }; $default_value }; $self->{q[weak_ref]} = $value;  }
    if ( exists($args->{q[writer]}) ) { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($args->{q[writer]}) and do { ref(\$args->{q[writer]}) eq 'SCALAR' or ref(\(my $val = $args->{q[writer]})) eq 'SCALAR' } }) && (do { local $_ = $args->{q[writer]}; length($_) > 0 })) or do { package Mite::Miteception; !defined($args->{q[writer]}) }) } or require Carp && Carp::croak(q[Type check failed in constructor: writer should be __ANON__|Undef]); $self->{q[writer]} = $args->{q[writer]};  }

    # Enforce strict constructor
    my @unknown = grep not( do { package Mite::Miteception; (defined and !ref and m{\A(?:(?:accessor|builder|c(?:l(?:ass|earer)|o(?:deref_default_variable|erce))|d(?:efault|ocumentation)|i(?:nit_arg|sa?)|lazy|name|predicate|re(?:ader|quired)|t(?:rigger|ype)|w(?:eak_ref|riter)))\z}) } ), keys %{$args}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));

    # Call BUILD methods
    !$no_build and @{$meta->{BUILD}||[]} and $self->BUILDALL($args);

    return $self;
}

sub BUILDALL {
    $_->(@_) for @{ $Mite::META{ref($_[0])}{BUILD} || [] };
}

sub __META__ {
    no strict 'refs';
    require mro;
    my $class = shift;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } reverse @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
    };
}

my $__XS = !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };

# Accessors for accessor
*accessor = sub { @_ > 1 ? do { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__|Undef]); $_[0]{q[accessor]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[accessor]}) ? $_[0]{q[accessor]} : ( $_[0]{q[accessor]} = do { my $default_value = $_[0]->_build_accessor; do { package Mite::Miteception; (((do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } }) && (do { local $_ = $default_value; length($_) > 0 })) or (!defined($default_value))) } or do { require Carp; Carp::croak(q[Type check failed in default: accessor should be __ANON__|Undef]) }; $default_value } ) ) } };

# Accessors for builder
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        exists_predicates => { q[has_builder] => q[builder] },
    );
}
else {
    *has_builder = sub { exists $_[0]->{q[builder]} };
}
*builder = sub { @_ > 1 ? do { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or (ref($_[1]) eq 'CODE') or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__|CodeRef|Undef]); $_[0]{q[builder]} = $_[1]; $_[0]; } : ( $_[0]{q[builder]} ) };

# Accessors for class
*class = sub { @_ > 1 ? do { (do { package Mite::Miteception; use Scalar::Util (); Scalar::Util::blessed($_[1]) }) or require Carp && Carp::croak(q[Type check failed in accessor: value should be Object]); $_[0]{q[class]} = $_[1]; require Scalar::Util && Scalar::Util::weaken($_[0]{q[class]}); $_[0]; } : ( $_[0]{q[class]} ) };

# Accessors for clearer
*clearer = sub { @_ > 1 ? do { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__|Undef]); $_[0]{q[clearer]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[clearer]}) ? $_[0]{q[clearer]} : ( $_[0]{q[clearer]} = do { my $default_value = $_[0]->_build_clearer; do { package Mite::Miteception; (((do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } }) && (do { local $_ = $default_value; length($_) > 0 })) or (!defined($default_value))) } or do { require Carp; Carp::croak(q[Type check failed in default: clearer should be __ANON__|Undef]) }; $default_value } ) ) } };

# Accessors for coderef_default_variable
*coderef_default_variable = sub { @_ > 1 ? do { do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } } or require Carp && Carp::croak(q[Type check failed in accessor: value should be Str]); $_[0]{q[coderef_default_variable]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[coderef_default_variable]}) ? $_[0]{q[coderef_default_variable]} : ( $_[0]{q[coderef_default_variable]} = do { my $default_value = do { our $__coderef_default_variable_DEFAULT__; $__coderef_default_variable_DEFAULT__->($_[0]) }; do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } } or do { require Carp; Carp::croak(q[Type check failed in default: coderef_default_variable should be Str]) }; $default_value } ) ) } };

# Accessors for coerce
*coerce = sub { @_ > 1 ? do { (!ref $_[1] and (!defined $_[1] or $_[1] eq q() or $_[1] eq '0' or $_[1] eq '1')) or require Carp && Carp::croak(q[Type check failed in accessor: value should be Bool]); $_[0]{q[coerce]} = $_[1]; $_[0]; } : ( $_[0]{q[coerce]} ) };

# Accessors for default
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        exists_predicates => { q[has_default] => q[default] },
    );
}
else {
    *has_default = sub { exists $_[0]->{q[default]} };
}
*default = sub { @_ > 1 ? do { do { package Mite::Miteception; !defined($_[1]) or do { package Mite::Miteception; (do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } } or (!!ref($_[1]))) } } or require Carp && Carp::croak(q[Type check failed in accessor: value should be Maybe[Str|Ref]]); $_[0]{q[default]} = $_[1]; $_[0]; } : ( $_[0]{q[default]} ) };

# Accessors for documentation
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        accessors => { q[documentation] => q[documentation] },
        exists_predicates => { q[has_documentation] => q[documentation] },
    );
}
else {
    *documentation = sub { @_ > 1 ? do { $_[0]{q[documentation]} = $_[1]; $_[0]; } : ( $_[0]{q[documentation]} ) };
    *has_documentation = sub { exists $_[0]->{q[documentation]} };
}

# Accessors for init_arg
*init_arg = sub { @_ > 1 ? do { do { package Mite::Miteception; (do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } } or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be Str|Undef]); $_[0]{q[init_arg]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[init_arg]}) ? $_[0]{q[init_arg]} : ( $_[0]{q[init_arg]} = do { my $default_value = do { our $__init_arg_DEFAULT__; $__init_arg_DEFAULT__->($_[0]) }; do { package Mite::Miteception; (do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } } or (!defined($default_value))) } or do { require Carp; Carp::croak(q[Type check failed in default: init_arg should be Str|Undef]) }; $default_value } ) ) } };

# Accessors for is
*is = sub { @_ > 1 ? do { do { package Mite::Miteception; (defined($_[1]) and !ref($_[1]) and $_[1] =~ m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z}) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be Enum["ro","rw","rwp","lazy","bare"]]); $_[0]{q[is]} = $_[1]; $_[0]; } : ( $_[0]{q[is]} ) };

# Accessors for isa
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        getters => { q[_isa] => q[isa] },
    );
}
else {
    *_isa = sub { @_ > 1 ? require Carp && Carp::croak("isa is a read-only attribute of @{[ref $_[0]]}") : $_[0]{q[isa]} };
}

# Accessors for lazy
*lazy = sub { @_ > 1 ? do { (!ref $_[1] and (!defined $_[1] or $_[1] eq q() or $_[1] eq '0' or $_[1] eq '1')) or require Carp && Carp::croak(q[Type check failed in accessor: value should be Bool]); $_[0]{q[lazy]} = $_[1]; $_[0]; } : ( $_[0]{q[lazy]} ) };

# Accessors for name
*name = sub { @_ > 1 ? do { ((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__]); $_[0]{q[name]} = $_[1]; $_[0]; } : ( $_[0]{q[name]} ) };

# Accessors for predicate
*predicate = sub { @_ > 1 ? do { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__|Undef]); $_[0]{q[predicate]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[predicate]}) ? $_[0]{q[predicate]} : ( $_[0]{q[predicate]} = do { my $default_value = $_[0]->_build_predicate; do { package Mite::Miteception; (((do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } }) && (do { local $_ = $default_value; length($_) > 0 })) or (!defined($default_value))) } or do { require Carp; Carp::croak(q[Type check failed in default: predicate should be __ANON__|Undef]) }; $default_value } ) ) } };

# Accessors for reader
*reader = sub { @_ > 1 ? do { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__|Undef]); $_[0]{q[reader]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[reader]}) ? $_[0]{q[reader]} : ( $_[0]{q[reader]} = do { my $default_value = $_[0]->_build_reader; do { package Mite::Miteception; (((do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } }) && (do { local $_ = $default_value; length($_) > 0 })) or (!defined($default_value))) } or do { require Carp; Carp::croak(q[Type check failed in default: reader should be __ANON__|Undef]) }; $default_value } ) ) } };

# Accessors for required
*required = sub { @_ > 1 ? do { (!ref $_[1] and (!defined $_[1] or $_[1] eq q() or $_[1] eq '0' or $_[1] eq '1')) or require Carp && Carp::croak(q[Type check failed in accessor: value should be Bool]); $_[0]{q[required]} = $_[1]; $_[0]; } : ( $_[0]{q[required]} ) };

# Accessors for trigger
if ( $__XS ) {
    Class::XSAccessor->import(
        chained => 1,
        exists_predicates => { q[has_trigger] => q[trigger] },
    );
}
else {
    *has_trigger = sub { exists $_[0]->{q[trigger]} };
}
*trigger = sub { @_ > 1 ? do { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or (ref($_[1]) eq 'CODE') or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__|CodeRef|Undef]); $_[0]{q[trigger]} = $_[1]; $_[0]; } : ( $_[0]{q[trigger]} ) };

# Accessors for type
*type = sub { @_ > 1 ? require Carp && Carp::croak("type is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[type]}) ? $_[0]{q[type]} : ( $_[0]{q[type]} = do { my $default_value = $_[0]->_build_type; do { package Mite::Miteception; ((do { package Mite::Miteception; use Scalar::Util (); Scalar::Util::blessed($default_value) }) or (!defined($default_value))) } or do { require Carp; Carp::croak(q[Type check failed in default: type should be Object|Undef]) }; $default_value } ) ) };

# Accessors for weak_ref
*weak_ref = sub { @_ > 1 ? do { (!ref $_[1] and (!defined $_[1] or $_[1] eq q() or $_[1] eq '0' or $_[1] eq '1')) or require Carp && Carp::croak(q[Type check failed in accessor: value should be Bool]); $_[0]{q[weak_ref]} = $_[1]; $_[0]; } : ( $_[0]{q[weak_ref]} ) };

# Accessors for writer
*writer = sub { @_ > 1 ? do { do { package Mite::Miteception; (((do { package Mite::Miteception; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } }) && (do { local $_ = $_[1]; length($_) > 0 })) or (!defined($_[1]))) } or require Carp && Carp::croak(q[Type check failed in accessor: value should be __ANON__|Undef]); $_[0]{q[writer]} = $_[1]; $_[0]; } : do { ( exists($_[0]{q[writer]}) ? $_[0]{q[writer]} : ( $_[0]{q[writer]} = do { my $default_value = $_[0]->_build_writer; do { package Mite::Miteception; (((do { package Mite::Miteception; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } }) && (do { local $_ = $default_value; length($_) > 0 })) or (!defined($default_value))) } or do { require Carp; Carp::croak(q[Type check failed in default: writer should be __ANON__|Undef]) }; $default_value } ) ) } };


1;
}