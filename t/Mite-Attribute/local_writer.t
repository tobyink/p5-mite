#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "required" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has foo =>
    is => 'rw',
    isa => 'Int',
    local_writer => 1;

package MyTest2;
use Mite::Shim;
extends 'MyTest';
has '+foo' => predicate => 1;
1;
CODE

   	my $o = MyTest->new( foo => 99 );
    do {
        my $guard = $o->locally_set_foo( 66 );
        is( $o->foo, 66 );
        is( $guard->peek, 99 );
    };
    is( $o->foo, 99 );

    my $o2 = MyTest2->new;
    ok ! $o2->has_foo;
    do {
        my $guard = $o2->locally_set_foo( 66 );
        ok $o2->has_foo;
        is( $o2->foo, 66 );
        is( $guard->peek, undef );
    };
    ok ! $o2->has_foo;

    my $o3 = MyTest->new( foo => 99 );
    do {
        my $guard = $o3->locally_set_foo( 66 );
        is( $o3->foo, 66 );
        $guard->dismiss;
    };
    is( $o3->foo, 66 );

    my $o4 = MyTest->new( foo => 99 );
    do {
        my $guard = $o4->locally_set_foo( 66 );
        is( $o4->foo, 66 );
        $guard->restore;
        is( $o4->foo, 99 );
    };
    is( $o4->foo, 99 );

    my $o5 = MyTest2->new( foo => 99 );
    ok $o5->has_foo;
    do {
        my $guard = $o5->locally_set_foo;
        ok ! $o5->has_foo;
        is( $o5->foo, undef );
        is( $guard->peek, 99 );
        $o5->foo( 66 );
        ok $o5->has_foo;
        is( $o5->foo, 66 );
    };
    ok $o5->has_foo;
    is $o5->foo, 99;
};

done_testing;
