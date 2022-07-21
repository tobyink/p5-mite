#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "handles" => sub {
    mite_load <<'CODE';
package Thingy;
use Mite::Shim;
has xyz =>
    is => 'ro';

package MyTest;
use Mite::Shim;
has foo =>
    is => 'rw',
    required => 1,
    handles => {
        xyz => 'xyz',
        bar => 'xyz',
    };

package MyTest2;
use Mite::Shim;
has foo =>
    is => 'rw',
    required => 1,
    handles => {
        '%s_xyz' => 'xyz',
        '%s_bar' => 'xyz',
    };

1;
CODE

    my $thingy = Thingy->new( xyz => 42 );

    {
        my $object = MyTest->new( foo => $thingy );
        is( $object->xyz, 42 );
        is( $object->bar, 42 );
    }

    {
        my $object = MyTest->new( foo => 42 );
        local $@;
        eval { $object->xyz };
        my $e = $@;
        like $e, qr/^foo is not a blessed object/;
    }

    {
        my $object = MyTest2->new( foo => $thingy );
        is( $object->foo_xyz, 42 );
        is( $object->foo_bar, 42 );
    }
};


tests "persistence with lazy builder" => sub {
    mite_load <<'CODE';
package RandomThing;
use Mite::Shim;
has number =>
    is => 'ro',
    builder => sub { rand() };

package GatewayToRandom;
use Mite::Shim;
has random_thing =>
    is => 'lazy',
    builder => sub { RandomThing->new },
    handles => [ 'number' ];

1;
CODE

    my $object = 'GatewayToRandom'->new;
    my $first  = $object->number;

    is( $object->number, $first );
    is( $object->number, $first );
    is( $object->number, $first );
    is( $object->number, $first );
    is( $object->number, $first );
    is( $object->number, $first );
    is( $object->number, $first );
    is( $object->number, $first );
};

done_testing;
