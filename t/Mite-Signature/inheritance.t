#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

my $has_new_type_params = eval "use Type::Params 1.015 (); 1";

$has_new_type_params and tests "basic inheritance" => sub {
    mite_load <<'CODE';
package MyTest1;
use Mite::Shim -all;

signature_for foo => (
    named => [ xxx => "Int", yyy => "Bool" ],
);

sub foo {
    my ( $self, $arg ) = @_;
    return [ $arg->xxx, $arg->yyy ];
}

package MyTest2;
use Mite::Shim -all;
extends 'MyTest1';

signature_for '+foo';

sub foo {
    my ( $self, $arg ) = @_;
    return [ $arg->xxx, $arg->yyy ];
}

1;
CODE

    {
        my $got = MyTest2->foo( xxx => 42, yyy => 1 );
        is( $got, [ 42, 1 ], 'simple pass' );
    }

    {
        my $got = MyTest2->foo( xxx => 42, yyy => 42 );
        is( $got, [ 42, !!1 ], 'simple coerce' );
    }

    {
        my $e = dies {
            MyTest2->foo( xxx => "Hello world", yyy => 1 );
        };
        like( $e, qr/Type check failed in signature for foo: \S+ should be Int/, 'simple type fail' );
    }

    {
        my $e = dies {
            MyTest2->foo( xxx => 66 );
        };
        like( $e, qr/Wrong number of parameters in signature for foo/, 'simple count fail' );
    }
};

$has_new_type_params and tests "advanced inheritance" => sub {
    mite_load <<'CODE';
package MyTest3;
use Mite::Shim -all;

signature_for foo => (
    named => [ xxx => "Int", yyy => "Bool" ],
);

sub foo {
    my ( $self, $arg ) = @_;
    return [ $arg->xxx, $arg->yyy ];
}

package MyTest4;
use Mite::Shim -all;
extends 'MyTest3';

signature_for '+foo' => (
    head  => [ 'Str' ],
    named => [ zzz => 'Any' ],
);

sub foo {
    my ( $self, $arg ) = @_;
    return [ $arg->xxx, $arg->yyy, $arg->zzz ];
}

1;
CODE

    {
        my $got = MyTest4->foo( xxx => 42, yyy => 1, zzz => 2 );
        is( $got, [ 42, 1, 2 ], 'simple pass' );
    }

    {
        my $e = dies {
            MyTest4->new->foo( xxx => 66, yyy => 9999, zzz => 2 );
        };
        like( $e, qr/Type check failed in signature for foo/, 'head was overridden' );
    }
};

ok 1;

done_testing;
