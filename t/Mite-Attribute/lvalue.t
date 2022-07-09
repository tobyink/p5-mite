#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "required" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has foo => ( lvalue => 1 );
1;
CODE

    my $o = MyTest->new( foo => 99 );
    is $o->foo, 99;
    $o->foo = 66;
    is $o->foo, 66;
};

tests "errors" => sub {
    my $e;
    require Mite::Attribute;
    require Mite::Class;

    $e = do {
        local $@;
        eval {
            Mite::Attribute->new(
                name      => 'foo',
                lvalue    => 1,
                lazy      => 1,
            );
        };
        $@;
    };
    like $e, qr/Attributes with lazy defaults cannot have an lvalue accessor/;

    $e = do {
        local $@;
        eval {
            Mite::Attribute->new(
                name      => 'foo',
                lvalue    => 1,
                weak_ref  => 1,
            );
        };
        $@;
    };
    like $e, qr/Attributes with weak_ref cannot have an lvalue accessor/;

    $e = do {
        local $@;
        eval {
            Mite::Attribute->new(
                name      => 'foo',
                lvalue    => 1,
                isa       => 'Int',
                class     => Mite::Class->new( name => 'MyTest' ),
            );
        };
        $@;
    };
    like $e, qr/Attributes with type constraints or coercions cannot have an lvalue accessor/;

    $e = do {
        local $@;
        eval {
            Mite::Attribute->new(
                name      => 'foo',
                lvalue    => 1,
                trigger   => 1,
            );
        };
        $@;
    };
    like $e, qr/Attributes with triggers cannot have an lvalue accessor/;
};

done_testing;
