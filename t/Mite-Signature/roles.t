#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "basic test with roles" => sub {
    mite_load <<'CODE';
package MyTest::R;
use Mite::Shim -role, -all;

signature_for foo => (
    pos => [ "Int", "Bool" ],
);

package MyTest;
use Mite::Shim;
with 'MyTest::R';

sub foo {
    my ( $self, $int, $bool ) = @_;
    return [ $int, $bool ];
}
1;
CODE

    {
        my $got = MyTest->foo( 42, 1 );
        is( $got, [ 42, 1 ], 'simple pass' );
    }

    {
        my $got = MyTest->foo( 42, 42 );
        is( $got, [ 42, !!1 ], 'simple coerce' );
    }

    {
        my $e = dies {
            MyTest->foo( "Hello world", 1 );
        };
        like( $e, qr/Type check failed in signature for foo: \S+ should be Int/, 'simple type fail' );
    }

    {
        my $e = dies {
            MyTest->foo( 66 );
        };
        like( $e, qr/Wrong number of parameters in signature for foo/, 'simple count fail' );
    }
};

done_testing;
