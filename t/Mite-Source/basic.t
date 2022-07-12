#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;
use Scalar::Util qw(refaddr);

tests "class_for" => sub {
    my $source = sim_source;

    my $foo = $source->class_for("Foo");
    my $bar = $source->class_for("Bar");

    is refaddr($foo->source), refaddr($source);
    is refaddr($bar->source), refaddr($source);

    isnt refaddr($foo), refaddr($bar);
    is refaddr($foo), refaddr($source->class_for("Foo")), "classes are cached";
    is refaddr($bar), refaddr($source->class_for("Bar")), "  double check that";

    ok $source->has_class("Foo");
    ok $source->has_class("Bar");
    ok !$source->has_class("Baz");
};

tests "add_classes" => sub {
    my $source = sim_source;

    my @classes = (sim_class, sim_class);
    $source->add_classes( @classes );

    for my $class (@classes) {
        ok $source->has_class($class->name);
        is refaddr($class->source), refaddr($source);
    }
};

tests "compiled" => sub {
    my $source = sim_source;
    my $compiled = $source->compiled;

    isa_ok $compiled, "Mite::Compiled";
    is refaddr($compiled->source), refaddr($source);

    is refaddr($source->compiled), refaddr($compiled), "compiled is cached";
};

tests "project" => sub {
    my $source = sim_source;
    isa_ok $source->project, "Mite::Project";
};

done_testing;
