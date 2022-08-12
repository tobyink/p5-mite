#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "basic test with roles" => sub {
    mite_load <<'CODE';
package MyTest::R;
use Mite::Shim -role, -runtime;

has foo => ( is => 'rwp', handles => [ 'quux' ] );

sub foobar {
    return 123;
}

package MyTest;
use Mite::Shim;
1;
CODE

    my $o = MyTest->new;
    ok ! $o->can( 'foobar' );
    ok ! $o->does( 'MyTest::R' );
    ok ! $o->DOES( 'MyTest::R' );

    MyTest::R::APPLY_TO( $o );
    ok $o->can( 'foobar' );
    is $o->foobar, 123;
    ok $o->does( 'MyTest::R' );
    ok $o->DOES( 'MyTest::R' );

    $o->_set_foo( 456 );
    is $o->foo, 456;

    $o->can( 'quux' );
    my $e = do {
        local $@;
        eval { $o->quux };
        $@;
    };
    like $e, qr/foo is not a blessed object/;

    ok ! MyTest->can( 'foobar' );
};

done_testing;
