#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

use Mite::Attribute;

tests "Simple values which pass" => sub {
    mite_load <<'CODE';
package Foo;
use Mite::Shim;
has num =>
   is => 'rw',
   isa => 'Int',
   default => 99;
1;
CODE

    my $obj = Foo->new( num => 42 );
    $obj->num( 23 );
    is $obj->num, 23;
};

tests "Fail in the constructor" => sub {
    mite_load <<'CODE';
package Foo2;
use Mite::Shim;
has num =>
   is => 'rw',
   isa => 'Int',
   default => 99;
1;
CODE

    local $@;
    eval {
        my $obj = Foo2->new( num => "Hello" );
    };
    my $e = $@;
    like $e, qr/Type check failed in constructor/;
};

tests "Fail in the accessor" => sub {
    mite_load <<'CODE';
package Foo3;
use Mite::Shim;
has num =>
   is => 'rw',
   isa => 'Int',
   default => 99;
1;
CODE

    my $obj = Foo3->new( num => 42 );
    local $@;
    eval {
        $obj->num( "Hello" );
    };
    my $e = $@;
    like $e, qr/Type check failed in accessor/;
};

tests "Types::Common::Numeric works" => sub {
    mite_load <<'CODE';
package FooPos;
use Mite::Shim;
has num =>
   is => 'rw',
   isa => 'PositiveInt';
1;
CODE

    my $obj = FooPos->new( num => 42 );
    $obj->num( 23 );
    is $obj->num, 23;

    local $@;
    eval {
        $obj->num( -12 );
    };
    my $e = $@;
    like $e, qr/Type check failed in accessor/;
};

tests "Sub::Quote type constraints work" => sub {
    eval { require Sub::Quote; 1 } or do {
        ok 1;
        return;
    };

    mite_load <<'CODE';
package FooCR;
use Mite::Shim;
use Sub::Quote qw(quote_sub);
has num =>
   is => 'rw',
   isa => quote_sub q{ $_[0] > 0 };
1;
CODE

    my $obj = FooCR->new( num => 42 );
    $obj->num( 23 );
    is $obj->num, 23;

    local $@;
    eval {
        $obj->num( -12 );
    };
    my $e = $@;
    like $e, qr/Type check failed in accessor/;
};

tests "StrMatch" => sub {
    mite_load <<'CODE';
package FooMatch;
use Mite::Shim;
use Types::Standard qw( StrMatch );
has attr =>
   is => 'rw',
   isa => StrMatch[ qr/A/i ];
1;
CODE

    my $obj = FooMatch->new( attr => 'apple' );
    $obj->attr( 'banana' );
    is $obj->attr, 'banana';

    local $@;
    eval {
        $obj->attr( 'cucumber' );
    };
    my $e = $@;
    like $e, qr/Type check failed in accessor/;
};

done_testing;
