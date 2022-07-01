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

tests "subs" => sub {
    mite_load <<'CODE';
package OurTest1;
use Mite::Shim -role;
has [qw/ foo bar baz /] => ( is => 'ro' );

sub get_foo { shift->foo }
sub get_bar { shift->bar }
sub get_baz { shift->baz }

package OurTest2;
use Mite::Shim -role;
with 'OurTest1';

sub get_bar { 'bar' }

package OurTest3;
use Mite::Shim;
with 'OurTest2';

sub get_baz { 'baz' }

1;
CODE

    no warnings 'once';
    is $OurTest1::USES_MITE, 'Mite::Role', '$USES_MITE';
    ok( OurTest1->can('get_foo'), 'Roles do have methods' );

    my $object = OurTest3->new( foo => 24 );
    is $object->get_foo(), 24, 'Method copied from role to class';
    is $object->get_bar(), 'bar', 'Method copied from other role to class';
    is $object->get_baz(), 'baz', 'Native method overrides role';
};

done_testing;
