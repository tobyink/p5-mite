#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

eval { require Role::Tiny; require Role::Hooks; 1 }
and tests "test Role::Hooks works" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
with 'Test::RoleTinyYetAnotherRole';
1;
CODE

    no warnings 'once';
    is_deeply(
        \@Test::RoleTinyYetAnotherRole::LOG,
        [ [ 'Test::RoleTinyYetAnotherRole', 'MyTest' ] ],
    );
};

ok 1;

done_testing;
