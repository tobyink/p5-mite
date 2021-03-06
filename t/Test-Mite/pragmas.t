#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "strict" => sub {
    like dies { ${"foo"} = 23 }, qr{\QCan't use string ("foo") as a SCALAR ref};
};

tests "warnings" => sub {
    like warning { 0+undef }, qr{\QUse of uninitialized value};
};

tests "feature 5.10" => sub {
    lives_ok {
        state $foo = 23;
        is $foo, 23;
    };
};

done_testing;
