#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

tests "trusted eager default" => sub {
    mite_load <<'CODE';
package MyTest1;
use Mite::Shim;
has truthy =>
  is      => 'rw',
  isa     => 'Bool',
  coerce  => !!1,
  default => sub { 42 },
  default_is_trusted => !!1;
1;
CODE

    is( MyTest1->new->truthy, 42 );

    isnt( MyTest1->new(truthy => 33)->truthy, 33 );
    is( MyTest1->new(truthy => 33)->truthy, !!1 );

    isnt( MyTest1->new->truthy(33)->truthy, 33 );
    is( MyTest1->new->truthy(33)->truthy, !!1 );
};

tests "trusted lazy default" => sub {
    mite_load <<'CODE';
package MyTest2;
use Mite::Shim;
has truthy =>
  is      => 'rw',
  isa     => 'Bool',
  coerce  => !!1,
  lazy    => !!1,
  default => sub { 42 },
  default_is_trusted => !!1;
1;
CODE

    is( MyTest2->new->truthy, 42 );

    isnt( MyTest2->new(truthy => 33)->truthy, 33 );
    is( MyTest2->new(truthy => 33)->truthy, !!1 );

    isnt( MyTest2->new->truthy(33)->truthy, 33 );
    is( MyTest2->new->truthy(33)->truthy, !!1 );
};

tests "untrusted eager default" => sub {
    mite_load <<'CODE';
package MyTest3;
use Mite::Shim;
has truthy =>
  is      => 'rw',
  isa     => 'Bool',
  coerce  => !!1,
  default => sub { 42 },
  default_is_trusted => !!0;
1;
CODE

    isnt( MyTest3->new->truthy, 42 );
    is( MyTest3->new->truthy, !!1 );

    isnt( MyTest3->new(truthy => 33)->truthy, 33 );
    is( MyTest3->new(truthy => 33)->truthy, !!1 );

    isnt( MyTest3->new->truthy(33)->truthy, 33 );
    is( MyTest3->new->truthy(33)->truthy, !!1 );
};

tests "untrusted lazy default" => sub {
    mite_load <<'CODE';
package MyTest4;
use Mite::Shim;
has truthy =>
  is      => 'rw',
  isa     => 'Bool',
  coerce  => !!1,
  lazy    => !!1,
  default => sub { 42 },
  default_is_trusted => !!0;
1;
CODE

    isnt( MyTest4->new->truthy, 42 );
    is( MyTest4->new->truthy, !!1 );

    isnt( MyTest4->new(truthy => 33)->truthy, 33 );
    is( MyTest4->new(truthy => 33)->truthy, !!1 );

    isnt( MyTest4->new->truthy(33)->truthy, 33 );
    is( MyTest4->new->truthy(33)->truthy, !!1 );
};

done_testing;
