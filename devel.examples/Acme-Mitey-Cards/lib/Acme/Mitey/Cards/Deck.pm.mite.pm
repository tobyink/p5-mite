{
package Acme::Mitey::Cards::Deck;
use strict;
use warnings;

BEGIN {
    require Acme::Mitey::Cards::Set;

    use mro 'c3';
    our @ISA;
    push @ISA, q[Acme::Mitey::Cards::Set];
}

sub new {
    my $class = shift;
    my $args  = { ( @_ == 1 ) ? %{$_[0]} : @_ };

    my $self = bless {}, $class;

    if ( exists($args->{q[cards]}) ) { (do { package Type::Tiny; ref($args->{q[cards]}) eq 'ARRAY' } and do { my $ok = 1; for my $i (@{$args->{q[cards]}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok }) or do { require Carp; Carp::croak(q[Type check failed in constructor: cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $self->{q[cards]} = delete $args->{q[cards]};  }
    if ( exists($args->{q[original_cards]}) ) { (do { package Type::Tiny; ref($args->{q[original_cards]}) eq 'ARRAY' } and do { my $ok = 1; for my $i (@{$args->{q[original_cards]}}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok }) or do { require Carp; Carp::croak(q[Type check failed in constructor: original_cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $self->{q[original_cards]} = delete $args->{q[original_cards]};  }
    if ( exists($args->{q[reverse]}) ) { do { package Type::Tiny; defined($args->{q[reverse]}) and do { ref(\$args->{q[reverse]}) eq 'SCALAR' or ref(\(my $val = $args->{q[reverse]})) eq 'SCALAR' } } or do { require Carp; Carp::croak(q[Type check failed in constructor: reverse should be Str]) }; $self->{q[reverse]} = delete $args->{q[reverse]};  } else { $self->{q[reverse]} = do { my $default_value = "plain"; do { package Type::Tiny; defined($default_value) and do { ref(\$default_value) eq 'SCALAR' or ref(\(my $val = $default_value)) eq 'SCALAR' } } or do { require Carp; Carp::croak(q[Type check failed in default: reverse should be Str]) }; $default_value };  }

    keys %$args and do { require Carp; Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort keys %$args)) };

    return $self;
}

if( !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor } ) {
*original_cards = sub { @_ > 1 ? require Carp && Carp::croak("original_cards is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[original_cards]}) ? $_[0]{q[original_cards]} : ( $_[0]{q[original_cards]} = do { my $default_value = $_[0]->_build_original_cards; do { package Type::Tiny; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: original_cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $default_value } ) ) };

}
else {
    *original_cards = sub { @_ > 1 ? require Carp && Carp::croak("original_cards is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[original_cards]}) ? $_[0]{q[original_cards]} : ( $_[0]{q[original_cards]} = do { my $default_value = $_[0]->_build_original_cards; do { package Type::Tiny; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: original_cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $default_value } ) ) };

}
if( !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor } ) {
*cards = sub { @_ > 1 ? require Carp && Carp::croak("cards is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[cards]}) ? $_[0]{q[cards]} : ( $_[0]{q[cards]} = do { my $default_value = $_[0]->_build_cards; do { package Type::Tiny; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $default_value } ) ) };

}
else {
    *cards = sub { @_ > 1 ? require Carp && Carp::croak("cards is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[cards]}) ? $_[0]{q[cards]} : ( $_[0]{q[cards]} = do { my $default_value = $_[0]->_build_cards; do { package Type::Tiny; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $default_value } ) ) };

}
if( !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor } ) {
Class::XSAccessor->import(
    getters => { q[reverse] => q[reverse] },
);

}
else {
    *reverse = sub { @_ > 1 ? require Carp && Carp::croak("reverse is a read-only attribute of @{[ref $_[0]]}") : $_[0]->{q[reverse]} };

}

1;
}