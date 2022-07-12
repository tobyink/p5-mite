#!/usr/bin/perl

use lib 't/lib';
use Test::Mite with_recommends => 1;

tests "parents as objects" => sub {
    my $child  = sim_class( name => "C1" );

    my $names_match = sub {
        my ( $got, $expected, @desc ) = @_;
        @_ = ( [ map $_->name, @$got ], [ map $_->name, @$expected ], @desc );
        goto \&is;
    };

    # Test simple multiple inheritance
    my(@parents) = (
        sim_class( name => "P1" ),
        sim_class( name => "P2")
    );
    $child->superclasses([map { $_->name } @parents]);

    $names_match->( $child->parents, \@parents );
    is [$child->get_isa],    [map { $_->name } @parents];
    is [$child->linear_isa], [$child->name, map { $_->name } @parents];
    $names_match->( [$child->linear_parents], [$child, @parents] );


    # Test parents is reset when extends is reset
    my(@new_parents) = (
        sim_class( name => "NP1" ),
        sim_class( name => "NP2")
    );
    $child->superclasses([map { $_->name } @new_parents]);
    $names_match->( $child->parents, \@new_parents, "YOU'RE NOT MY REAL PARENTS!!" );
    is( [$child->get_isa],    [map { $_->name } @new_parents] );
    is( [$child->linear_isa], [$child->name, map { $_->name } @new_parents] );
    $names_match->( [$child->linear_parents], [$child, @new_parents] );

    # Test diamond inheritance, ensure C3 style is in use
    my $grand_parent = sim_class( name => "GP1" );
    $new_parents[0]->superclasses([ $grand_parent->name ]);
    $new_parents[1]->superclasses([ $grand_parent->name ]);

    is [$child->linear_isa], [
        map { $_->name } $child, @new_parents, $grand_parent
    ], "diamond inheritance";
};


tests "c3 inheritance" => sub {
    # Set up diamond inheritance
    mite_load <<'CODE';
package xGP;
use Mite::Shim;

package xP1;
use Mite::Shim;
extends "xGP";

package xP2;
use Mite::Shim;
extends "xGP";

package xC1;
use Mite::Shim;
extends "xP1", "xP2";

1;
CODE

    require mro;
    is mro::get_linear_isa("xC1"), [qw(xC1 xP1 xP2 xGP)];
};

done_testing;
