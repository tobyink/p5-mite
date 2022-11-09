#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "locked" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has foo => (
    is          => 'rw',
    isa         => 'ArrayRef[Int]',
    default     => [],
    locked      => 1,
    handles     => { add_foo => 'push' },
    handles_via => 'Array',
);
1;
CODE

    my $o = MyTest->new();
    is( $o->foo, [] );
    
    $o->add_foo( 1 .. 3 );
    is( $o->foo, [ 1..3 ] );
    
    my $e = dies {
        push @{ $o->foo }, 4;
    };
    like $e, qr/read.?only/i;
    is( $o->foo, [ 1..3 ] );
    
    $o->foo( [ 2..10 ] );
    is( $o->foo, [ 2..10 ] );
    
    $o->add_foo( 11 );
    is( $o->foo, [ 2..11 ] );
};

done_testing;
