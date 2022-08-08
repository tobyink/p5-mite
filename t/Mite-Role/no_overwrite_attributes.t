#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "alias and excludes role methods" => sub {
    mite_load <<'CODE';
package MyTest1;
use Mite::Shim -role;
has abc => 123;

package MyTest2;
use Mite::Shim;
has abc => 456;
with 'MyTest1';

1;
CODE

    my $o = MyTest2->new;
    is $o->abc, 456;
};

done_testing;
