#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "basic test of roles" => sub {
    mite_load <<'CODE';
package MyTest1;
use Mite::Shim -role;
around [ 'xyz', 'zyx' ] => sub {
    my ( $next, $self, @args ) = @_;
    uc( $self->$next( @args ) );
};

package MyTest2;
use Mite::Shim;
with 'MyTest1';
sub xyz {
    my ( $self, @args ) = @_;
    return join q[, ], @args;
}
sub zyx {
    return 'zzz';
}

1;
CODE

    no warnings 'once';
    is MyTest2->xyz( 'a', 'b' ), 'A, B';
};

done_testing;
