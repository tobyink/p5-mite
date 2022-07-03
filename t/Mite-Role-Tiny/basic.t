#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "basic test of roles" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
with 'Test::RoleTinyRole';
sub bar { "BAR" }
sub baz { 'BZZT' }
sub quuux { 'BZZT' }
1;
CODE

    my $object = MyTest->new;
    ok $object->DOES( 'Test::RoleTinyRole' );
    is $object->foo, 'FOO';
    is $object->bar, 'BAR';
    is $object->baz, 'BAZ';
    is $object->quux, 'QUUX';
    is $object->quuux, 'QUUUX';
};

done_testing;
