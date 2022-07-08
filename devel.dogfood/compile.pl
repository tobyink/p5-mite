#!/usr/bin/env perl
use v5.34;
use warnings;
use FindBin qw($Bin);
#use lib "$Bin/../lib";
use Path::Tiny qw(path);
use Data::Dumper;

use Mite::Attribute;
use Mite::Class;
use Mite::Config;
use Mite::Project;

my $config  = Mite::Config->new( search_for_mite_dir => 1 );
my $project = Mite::Project->new( config => $config );

$project->{debug} = 1;
$project->{_limited_parsing} = 1;
$project->{_module_fakeout_namespace} = 'FakeOut';

Mite::Project->set_default( $project );

$project->load_directory;
$project->write_mites;
