#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;
use Scalar::Util qw(refaddr);

use Mite::Project;

tests "class() and source()" => sub {
    my $project = Mite::Project->new;

    my @sources = (sim_source, sim_source);
    $project->add_sources(@sources);

    my @classes = (
        $sources[0]->class_for( "Foo" ),
        $sources[1]->class_for( "Bar" ),
        $sources[1]->class_for( "Baz" )
    );

    is [ sort keys %{ $project->classes } ],
       [ sort map $_->name, @classes ];

    for my $class (@classes) {
        is refaddr($project->class($class->name)), refaddr($class);
    }

    for my $source (@sources) {
        is refaddr($project->source($source->file)), refaddr($source);
    }
};

done_testing;
