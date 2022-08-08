#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "alias and excludes role methods" => sub {
    mite_load <<'CODE';
package MyTest1;
use Mite::Shim -role;
sub abc { return 123 }
sub xyz {}

package MyTest2;
use Mite::Shim;
with 'MyTest1' => {
  -excludes => [ 'xyz' ],
  -alias    => { abc => 'def' },
};

1;
CODE

    my $o = MyTest2->new;
    is $o->def, 123;
    ok ! $o->can( 'abc' );
    ok ! $o->can( 'xyz' );
};

done_testing;
