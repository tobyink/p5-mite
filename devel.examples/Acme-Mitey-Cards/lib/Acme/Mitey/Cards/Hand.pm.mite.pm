{
package Acme::Mitey::Cards::Hand;
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
    if ( exists($args->{q[owner]}) ) { do { package Type::Tiny; (do { package Type::Tiny; defined($args->{q[owner]}) and do { ref(\$args->{q[owner]}) eq 'SCALAR' or ref(\(my $val = $args->{q[owner]})) eq 'SCALAR' } } or (do { package Type::Tiny; use Scalar::Util (); Scalar::Util::blessed($args->{q[owner]}) })) } or do { require Carp; Carp::croak(q[Type check failed in constructor: owner should be Str|Object]) }; $self->{q[owner]} = delete $args->{q[owner]};  }

    keys %$args and do { require Carp; Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort keys %$args)) };

    return $self;
}

if( !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor } ) {
*owner = sub { @_==1 or do { package Type::Tiny; (do { package Type::Tiny; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } } or (do { package Type::Tiny; use Scalar::Util (); Scalar::Util::blessed($_[1]) })) } or do { require Carp; Carp::croak(q[Type check failed in accessor: value should be Str|Object]) }; @_ > 1 ? ( $_[0]->{ q[owner] } = $_[1] ) : $_[0]->{q[owner]} };

}
else {
    *owner = sub { @_==1 or do { package Type::Tiny; (do { package Type::Tiny; defined($_[1]) and do { ref(\$_[1]) eq 'SCALAR' or ref(\(my $val = $_[1])) eq 'SCALAR' } } or (do { package Type::Tiny; use Scalar::Util (); Scalar::Util::blessed($_[1]) })) } or do { require Carp; Carp::croak(q[Type check failed in accessor: value should be Str|Object]) }; @_ > 1 ? ( $_[0]->{ q[owner] } = $_[1] ) : $_[0]->{q[owner]} };

}
if( !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor } ) {
*cards = sub { @_ > 1 ? require Carp && Carp::croak("cards is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[cards]}) ? $_[0]{q[cards]} : ( $_[0]{q[cards]} = do { my $default_value = $_[0]->_build_cards; do { package Type::Tiny; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $default_value } ) ) };

}
else {
    *cards = sub { @_ > 1 ? require Carp && Carp::croak("cards is a read-only attribute of @{[ref $_[0]]}") : ( exists($_[0]{q[cards]}) ? $_[0]{q[cards]} : ( $_[0]{q[cards]} = do { my $default_value = $_[0]->_build_cards; do { package Type::Tiny; (ref($default_value) eq 'ARRAY') and do { my $ok = 1; for my $i (@{$default_value}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($i) and $i->isa(q[Acme::Mitey::Cards::Card]) }) }; $ok } } or do { require Carp; Carp::croak(q[Type check failed in default: cards should be ArrayRef[InstanceOf["Acme::Mitey::Cards::Card"]]]) }; $default_value } ) ) };

}

1;
}