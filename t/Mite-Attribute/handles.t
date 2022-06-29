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

1;
CODE

    my $thingy = Thingy->new( xyz => 42 );
    my $object = MyTest->new( foo => $thingy );

    is( $object->xyz, 42 );
    is( $object->bar, 42 );

    {
        my $object = MyTest->new( foo => 42 );
        local $@;
        eval { $object->xyz };
        my $e = $@;
        like $e, qr/^foo is not a blessed object/;
    }
};

done_testing;
