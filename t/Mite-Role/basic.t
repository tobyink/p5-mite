#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "basic test of roles" => sub {
    mite_load <<'CODE';
package MyTest1;
use Mite::Shim -role;
has foo => ( is => 'ro' );

package MyTest2;
use Mite::Shim;
with 'MyTest1';

1;
CODE

    no warnings 'once';
    is $MyTest1::USES_MITE, 'Mite::Role', '$USES_MITE';
    ok !MyTest1->can('foo'), 'Roles do not have accessors';

    my $object = MyTest2->new( foo => 24 );
    is $object->foo, 24, 'Attribute copied from role to class';
};

tests "chained test of roles" => sub {
    mite_load <<'CODE';
package YourTest1;
use Mite::Shim -role;
has foo => ( is => 'ro' );

package YourTest2;
use Mite::Shim -role;
with 'YourTest1';

package YourTest3;
use Mite::Shim;
with 'YourTest2';

1;
CODE

    no warnings 'once';
    is $YourTest1::USES_MITE, 'Mite::Role', '$USES_MITE';
    ok !YourTest1->can('foo'), 'Roles do not have accessors';

    is $YourTest2::USES_MITE, 'Mite::Role', '$USES_MITE';
    ok !YourTest2->can('foo'), 'Roles do not have accessors';

    my $object = YourTest3->new( foo => 24 );
    is $object->foo, 24, 'Attribute copied from role to class';
};

done_testing;
