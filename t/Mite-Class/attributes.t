#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;
use Scalar::Util qw(refaddr);

tests "all_attributes" => sub {
    my $gparent = sim_class( name => "GP1" );
    my $parent  = sim_class( name => "P1" );
    my $child   = sim_class( name => "C1" );

    $parent->superclasses(["GP1"]);
    $child->superclasses(["P1"]);

    $gparent->add_attributes(
        sim_attribute( name => "from_gp" ),
        sim_attribute( name => "this" ),
    );
    $parent->add_attributes(
        sim_attribute( name => "from_p" ),
        sim_attribute( name => "in_p" ),
        sim_attribute( name => "that" )
    );
    $child->add_attributes(
        sim_attribute( name => "in_p" ),
        sim_attribute( name => "from_c" ),
    );

    is $gparent->all_attributes, hash {
        for my $attr ( keys %{ $gparent->attributes } ) {
            field $attr => object { call name => $attr; };
        }
        end;
    };

    is $parent->all_attributes, hash {
        field from_gp         => object { call name => 'from_gp' };
        field this            => object { call name => 'this' };
        field from_p          => object { call name => 'from_p' };
        field in_p            => object { call name => 'in_p' };
        field that            => object { call name => 'that' };
        end;
    };

    is $child->all_attributes, hash {
        field from_gp         => object { call name => 'from_gp' };
        field this            => object { call name => 'this' };
        field from_p          => object { call name => 'from_p' };
        field in_p            => object { call name => 'in_p' };
        field that            => object { call name => 'that' };
        field from_c          => object { call name => 'from_c' };
        end;
    };

    is $gparent->parents_attributes, {};
};


tests "extend_attribute" => sub {
    my $gparent = sim_class( name => "GP1" );
    my $parent  = sim_class( name => "P1" );
    my $child   = sim_class( name => "C1" );

    $parent->superclasses(["GP1"]);
    $child->superclasses(["P1"]);

    $gparent->add_attributes(
        sim_attribute( name => "foo", is => "ro", default => 23 ),
    );
    $child->extend_attribute(
        name    => "foo",
        default => sub { 99 }
    );

    my $extended_attribute = $child->attributes->{foo};
    is $extended_attribute->name,       "foo";
    is $extended_attribute->is,         "ro";
    is $extended_attribute->default->(), 99;
};

tests "strict_contructor" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has [ 'foo', 'foo2' ] =>
    is => 'rw',
    default => 99;
has xxx => ( init_arg => 'xxxx', is => 'ro' );
has yyy => ( init_arg => undef, is => 'ro' );
1;
CODE

    my $o = MyTest->new( xxxx => 42 );
    is $o->foo, 99;
    is $o->foo2, 99;
    is $o->xxx, 42;

    {
        local $@;
        my $o2 = eval { MyTest->new( bar => 66, baz => 33 ); };
        my $e = $@;
        like $e, qr/^Unexpected keys in constructor: bar, baz/;
    }

    {
        local $@;
        my $o2 = eval { MyTest->new( xxx => 1 ); };
        my $e = $@;
        like $e, qr/^Unexpected keys in constructor: xxx/;
    }

    {
        local $@;
        my $o2 = eval { MyTest->new( yyy => 1 ); };
        my $e = $@;
        like $e, qr/^Unexpected keys in constructor: yyy/;
    }
};

done_testing;
