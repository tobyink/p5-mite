#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

my $CLASS = 'Mite::Attribute';
require_ok $CLASS;

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


done_testing;
