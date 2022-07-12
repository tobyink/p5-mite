#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;
use Scalar::Util qw(refaddr);

tests "sim_source" => sub {
    my $source = sim_source();
    is $source->classes, {};
    ok -e $source->file;
    like $source->file, qr{\.pm$};
};


tests "sim_source with class name" => sub {
    my $source = sim_source(
        class_name      => "Foo::Bar"
    );

    like $source->file, qr{/Foo/Bar.pm$};
    is $source->classes, {};
};


tests "sim sources in the same project" => sub {
    is refaddr(sim_source->project), refaddr(sim_source->project);

    require Mite::Project;
    is refaddr(sim_source->project), refaddr(Mite::Project->default);
};


tests "sim_class" => sub {
    my $class = sim_class;
    ok $class->source->has_class($class->name);
    is refaddr($class->source->class_for($class->name)), refaddr($class);
};


tests "sim_project" => sub {
    isa_ok sim_project, "Mite::Project";
};


tests "sim_attribute" => sub {
    my $attr = sim_attribute;
    ok $attr->name, "->name";
};

done_testing;
