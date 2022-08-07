#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "handles_via => Array" => sub {
    mite_load <<'CODE';
package Thingy1;
use Mite::Shim;
has xyz =>
  is => 'ro',
  isa => 'ArrayRef[Bool]',
  coerce => 1,
  handles_via => 'Array',
  default => [],
  handles => {
    'push_%s'    => 'push',
    'pop_%s'     => 'pop',
    'push_true'  => [ push => {} ],  # a hashref is true!
    'push_false' => [ push =>  0 ],
  };
1;
CODE

    my $thing = Thingy1->new;
    $thing->push_xyz( 2 );
    $thing->push_xyz( undef );
    $thing->push_true;
    $thing->push_true;
    $thing->push_true;
    $thing->push_false;
    is(
        $thing->xyz,
        [ !!1, !!0, !!1, !!1, !!1, !!0 ],
    );
};

done_testing;
