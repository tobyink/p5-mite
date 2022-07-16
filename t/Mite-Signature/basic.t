#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "basic positional test" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim -all;

signature_for foo => (
    pos => [ "Int", "Bool" ],
);

sub foo {
    shift;
    return [ @_ ];
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

tests "basic named test" => sub {
    mite_load <<'CODE';
package MyTest2;
use Mite::Shim -all;

signature_for foo => (
    named => [ xxx => "Int", yyy => "Bool" ],
);

sub foo {
    my ( $self, $arg ) = @_;
    return [ $arg->xxx, $arg->yyy ];
}

signature_for bar => (
    named => [ xxx => "Num", yyy => "Object" ],
);

sub bar {
    die();
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

tests "basic named-to-list test" => sub {
    mite_load <<'CODE';
package MyTest3;
use Mite::Shim -all;

signature_for foo => (
    named => [ xxx => "Int", yyy => "Bool" ],
    named_to_list => true,
);

sub foo {
    my ( $self, @args ) = @_;
    return \@args;
}
1;
CODE

    {
        my $got = MyTest3->foo( xxx => 42, yyy => 1 );
        is( $got, [ 42, 1 ], 'simple pass' );
    }

    {
        my $got = MyTest3->foo( xxx => 42, yyy => 42 );
        is( $got, [ 42, !!1 ], 'simple coerce' );
    }

    {
        my $e = dies {
            MyTest3->foo( xxx => "Hello world", yyy => 1 );
        };
        like( $e, qr/Type check failed in signature for foo: \S+ should be Int/, 'simple type fail' );
    }

    {
        my $e = dies {
            MyTest3->foo( xxx => 66 );
        };
        like( $e, qr/Wrong number of parameters in signature for foo/, 'simple count fail' );
    }
};

tests "function test" => sub {
    mite_load <<'CODE';
package MyTest4;
use Mite::Shim -all;

signature_for foo => (
    pos => [ "Int", "Bool" ],
    method => false,
);

sub foo {
    return [ @_ ];
}
1;
CODE

    {
        my $got = MyTest4::foo( 42, 1 );
        is( $got, [ 42, 1 ], 'simple pass' );
    }

    {
        my $got = MyTest4::foo( 42, 42 );
        is( $got, [ 42, !!1 ], 'simple coerce' );
    }

    {
        my $e = dies {
            MyTest4::foo( "Hello world", 1 );
        };
        like( $e, qr/Type check failed in signature for foo: \S+ should be Int/, 'simple type fail' );
    }

    {
        my $e = dies {
            MyTest4::foo( 66 );
        };
        like( $e, qr/Wrong number of parameters in signature for foo/, 'simple count fail' );
    }
};

done_testing;
