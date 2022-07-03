#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "init order" => sub {
    mite_load <<'CODE';
my $order = 0;

package MyTest;
use Mite::Shim;
extends 'MyTest::Parent';
has third =>
    is => 'ro',
    default => sub { ++$order };
has fourth =>
    is => 'ro',
    default => sub { ++$order };

package MyTest::Parent;
use Mite::Shim;
has first =>
    is => 'ro',
    default => sub { ++$order };
has second =>
    is => 'ro',
    default => sub { ++$order };

1;
CODE

    my $o = MyTest->new;
    is $o->third, 3;
    is $o->fourth, 4;
    is $o->first, 1;
    is $o->second, 2;
};

tests "init order with plus" => sub {
    mite_load <<'CODE';
my $order = 0;

package MyTest2;
use Mite::Shim;
has second =>
    is => 'ro',
    default => sub { ++$order };
has first =>
    is => 'ro',
    default => sub { ++$order };
has '+second' =>
    documentation => 'Extended the attribute, so this now has later order';
1;
CODE

    my $o = MyTest2->new;
    is $o->second, 2;
    is $o->first, 1;
};

done_testing;
