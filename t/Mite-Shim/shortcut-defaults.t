#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "shortcut defaults" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has foo => 99;
has bar => sub { 66 };
1;
CODE

    my $o = MyTest->new;

    ok exists $o->{foo}, 'eager default';
    is $o->foo, 99, '... correct value';

    ok !exists $o->{bar}, 'lazy default';
    is $o->bar, 66, '... correct value';
};

done_testing;
