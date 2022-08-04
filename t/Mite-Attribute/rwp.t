#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

use Mite::Attribute;

BEGIN {
    package Foo;

    sub new {
        my $class = shift;
        bless { @_ }, $class
    }

    eval Mite::Attribute->new(
        name    => 'foo',
        is      => 'rwp',
    )->compile;
};

tests "Basic read-only" => sub {
    my $obj = new_ok 'Foo', [foo => 23];
    is $obj->foo, 23;
    like dies { $obj->foo("Flower child") },
        qr{usage:}i;
};

tests "Various tricky values" => sub {
    my $obj = new_ok 'Foo', [foo => undef];
    is $obj->foo, undef;

    $obj = new_ok 'Foo', [foo => 0];
    is $obj->foo, 0;

    $obj = new_ok 'Foo', [foo => ''];
    is $obj->foo, '';
};

tests "Private setter" => sub {
    my $obj = new_ok 'Foo', [foo => 23];
    is $obj->foo, 23;
    $obj->_set_foo( 42 );
    is $obj->foo, 42;
};

done_testing;
