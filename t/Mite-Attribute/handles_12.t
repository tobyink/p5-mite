#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "handles => 1" => sub {
    mite_load <<'CODE';
package Thingy1;
use Mite::Shim;
has xyz =>
  enum => [ qw( foo bar baz ) ],
  handles => 1;
1;
CODE

    my $thingy = Thingy1->new( xyz => "foo" );
    ok   $thingy->is_foo;
    ok ! $thingy->is_bar;
    ok ! $thingy->is_baz;
};

tests "handles => 2" => sub {
    mite_load <<'CODE';
package Thingy2;
use Mite::Shim;
has xyz =>
  enum => [ qw( foo bar baz ) ],
  handles => 2;
1;
CODE

    my $thingy = Thingy2->new( xyz => "foo" );
    ok   $thingy->xyz_is_foo;
    ok ! $thingy->xyz_is_bar;
    ok ! $thingy->xyz_is_baz;
};

done_testing;
