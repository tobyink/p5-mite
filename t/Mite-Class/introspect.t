#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;
use Scalar::Util qw(refaddr);

tests "project" => sub {
    my $class = sim_class;
    my $project = $class->project;
    isa_ok $project, 'Mite::Project';
};

tests "class" => sub {
    my $class = sim_class;
    my $project = $class->project;

    my $other_source = sim_source;
    $project->add_sources($other_source);

    my $other_class = $other_source->class_for("Foo::Bar");

    is refaddr($class->class("Foo::Bar")), refaddr($other_class);
    ok !$class->class("I::DO::NOT::EXIST");
};

done_testing;
