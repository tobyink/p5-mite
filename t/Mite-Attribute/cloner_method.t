#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

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

done_testing;
