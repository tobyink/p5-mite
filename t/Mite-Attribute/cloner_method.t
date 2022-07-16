#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;
use Scalar::Util qw(refaddr);

tests "clone => 1" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has foo => ( is => 'ro', clone => 1 );
1;
CODE

    my @arr = ( 1 .. 4 );
    my $o = MyTest->new( foo => \@arr );
    push @{ $o->foo }, 5;
    push @arr, 6;

    is $o->{foo}, [ 1 .. 4 ];
};

tests "clone => CODEREF" => sub {
    mite_load <<'CODE';
package MyTest2;
use Mite::Shim;
use Storable ();
has foo => (
    is => 'ro',
    clone => sub {
        my ( $self, $attrname, $value ) = @_;
        Storable::dclone( $value );
    },
);
1;
CODE

    my @arr = ( 1 .. 4 );
    my $o = MyTest2->new( foo => \@arr );
    push @{ $o->foo }, 5;
    push @arr, 6;

    is $o->{foo}, [ 1 .. 4 ];
};

tests "clone => METHODNAME" => sub {
    mite_load <<'CODE';
package MyTest3;
use Mite::Shim;
use Storable ();
has foo => (
    is => 'ro',
    clone => 'cloner_for_%s',
);
sub cloner_for_foo {
    my ( $self, $attrname, $value ) = @_;
    Storable::dclone( $value );
}
1;
CODE

    my @arr = ( 1 .. 4 );
    my $o = MyTest3->new( foo => \@arr );
    push @{ $o->foo }, 5;
    push @arr, 6;

    is $o->{foo}, [ 1 .. 4 ];
};

tests "clone_on_read / clone_on_write" => sub {
    mite_load <<'CODE';
package MyTest4;
use Mite::Shim;
has on_read => (
    is => 'rw',
    clone => 1,
    clone_on_read => 1,
    clone_on_write => 0,
);
has on_write => (
    is => 'rw',
    clone => 1,
    clone_on_read => 0,
    clone_on_write => 1,
);
has on_both => (
    is => 'rw',
    clone => 1,
    clone_on_read => 1,
    clone_on_write => 1,
);
has on_neither => (
    is => 'rw',
    clone => 1,
    clone_on_read => 0,
    clone_on_write => 0,
);
1;
CODE

    my $var1 = [];
    my $obj  = MyTest4->new(
        on_read    => $var1,
        on_write   => $var1,
        on_both    => $var1,
        on_neither => $var1,
    );
    is( refaddr($var1), refaddr($obj->{on_read}) );
    isnt( refaddr($var1), refaddr($obj->{on_write}) );
    isnt( refaddr($var1), refaddr($obj->{on_both}) );
    is( refaddr($var1), refaddr($obj->{on_neither}) );

    $obj->on_read( $var1 );
    $obj->on_write( $var1 );
    $obj->on_both( $var1 );
    $obj->on_neither( $var1 );
    is( refaddr($var1), refaddr($obj->{on_read}) );
    isnt( refaddr($var1), refaddr($obj->{on_write}) );
    isnt( refaddr($var1), refaddr($obj->{on_both}) );
    is( refaddr($var1), refaddr($obj->{on_neither}) );

    $obj->{on_read} = $obj->{on_write} = $obj->{on_both} = $obj->{on_neither} = $var1;
    isnt( refaddr($var1), refaddr($obj->on_read) );
    is( refaddr($var1), refaddr($obj->on_write) );
    isnt( refaddr($var1), refaddr($obj->on_both) );
    is( refaddr($var1), refaddr($obj->on_neither) );
};

done_testing;
