#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

# Adapted from HAARG/Moo-2.005004/source/t/no-build.t

tests "__no_BUILD__" => sub {
    mite_load <<'CODE';
package TestClass2;
use Mite::Shim;
extends 'TestClass1';

1;
CODE

    my $o = TestClass1->new;
    is $o->{build_called}, 1, 'mini class builder working';

    my $o2 = TestClass2->new;
    is $o2->{build_called}, 1, 'BUILD still called when extending mini class builder';
    is $o2->{no_build_used}, 1, '__no_BUILD__ was passed to mini builder';

    my $o3 = TestClass2->new({__no_BUILD__ => 1});
    is $o3->{build_called}, undef, '__no_BUILD__ inhibits Mite calling BUILD';
};

done_testing;
