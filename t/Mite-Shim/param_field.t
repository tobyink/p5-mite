#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "param and field" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim qw( param field -bool -unclean );
param foo => ();
field bar => ( builder => true );
sub _build_bar { 99 }
1;
CODE

    can_ok( 'MyTest', qw( has extends with before after around param field true false ) );

    {
        my $o = MyTest->new( foo => 66 );
        is $o->foo, 66;
        is $o->bar, 99;
    }

    {
        my $e = do {
            local $@;
            eval { my $o = MyTest->new(); };
            $@;
        };
        like $e, qr/Missing key in constructor: foo/;
    }

    {
        my $e = do {
            local $@;
            eval { my $o = MyTest->new( foo => 66, bar => 99 ); };
            $@;
        };
        like $e, qr/Unexpected keys in constructor: bar/;
    }
};

done_testing;
