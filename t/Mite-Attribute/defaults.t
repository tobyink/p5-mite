#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

require Mite::Attribute;
my $CLASS = 'Mite::Attribute';

tests has_default => sub {
    my $attr = new_ok $CLASS, [ name => "foo" ];
    ok !$attr->has_default;

    $attr->default(0);
    ok $attr->has_default, 'false default';

    $attr = new_ok $CLASS, [ name => "foo", default => undef ];
    ok $attr->has_default, 'has undef default';
};

tests has_simple_default => sub {
    my @simple_defaults = (
        "",
        0,
        23,
        "zero",
    );

    for my $default (@simple_defaults) {
        note "Default: $default";
        my $attr = new_ok $CLASS, [ name => "foo", default => $default ];
        ok $attr->has_default;
        ok $attr->has_simple_default;
        ok !$attr->has_coderef_default;
    }
};


tests has_coderef_default => sub {
    my @coderef_defaults = (
        sub { 23 }
    );

    for my $default (@coderef_defaults) {
        note "Default: $default";
        my $attr = new_ok $CLASS, [ name => "foo", default => $default ];
        ok $attr->has_default;
        ok !$attr->has_simple_default;
        ok $attr->has_coderef_default;
    }
};


tests coderef_default_variable => sub {
    require Mite::Class;
    my $mock_class = Mite::Class->new( name => 'Bar' );
    my $attr = new_ok $CLASS, [ name => "foo", class => $mock_class ];
    is $attr->coderef_default_variable, '$Bar::__foo_DEFAULT__';
};


tests "inline code defaults" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has list =>
    is => 'ro',
    default => \ '[ 1..4 ]';
1;
CODE

    my $o = MyTest->new;
    is( $o->list, [ 1..4 ] );
};

tests "arrayref default" => sub {
    mite_load <<'CODE';
package MyTest2;
use Mite::Shim;
has list =>
    is => 'ro',
    default => [];
1;
CODE

    my $o = MyTest2->new;
    is( $o->list, [] );
};

tests "hashref default" => sub {
    mite_load <<'CODE';
package MyTest3;
use Mite::Shim;
has list =>
    is => 'ro',
    default => {};
1;
CODE

    my $o = MyTest3->new;
    is( $o->list, {} );
};

done_testing;
