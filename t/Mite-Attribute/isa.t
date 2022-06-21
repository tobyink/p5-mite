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
package Foo;
use Mite::Shim;
has num =>
   is => 'rw',
   isa => 'Int',
   default => 99;
1;
CODE

    local $@;
    eval {
        my $obj = Foo->new( num => "Hello" );
    };
    my $e = $@;
    like $e, qr/Type check failed in constructor/;
};

tests "Fail in the accessor" => sub {
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
    local $@;
    eval {
        $obj->num( "Hello" );
    };
    my $e = $@;
    like $e, qr/Type check failed in accessor/;
};

done_testing;
