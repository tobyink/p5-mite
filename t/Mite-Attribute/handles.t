#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "required" => sub {
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

done_testing;
