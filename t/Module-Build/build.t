#!/usr/bin/perl

use lib 't/lib';
use Test::Mite;

use File::Copy::Recursive qw(dircopy);
use Path::Tiny;
use autodie;

my $Src_Project_Dir = 't/Module-Build/Some-Project';
my $Original_Dir = Path::Tiny->cwd;

tests "Build" => sub {
    env_for_mite();

    my $project_dir = Path::Tiny->tempdir;
    dircopy( $Src_Project_Dir, $project_dir );
    chdir $project_dir;

    mite_command("init", "Some::Project");

    is system("$^X", "Build.PL"), 0;
    is system('./Build'), 0;

    local @INC = ("blib/lib", @INC);
    require Some::Project;
    my $obj = new_ok 'Some::Project';
    cmp_deeply $obj->something, [23, 42];

    is system('./Build', "clean"), 0;

    ok !-e 'lib/Some/Project/Mite.pm';
    ok !-e 'lib/Some/Project.pm.mite.pm';

    # Simulate a release, no .mite directory.
    path(".mite")->remove_tree;

    is system("$^X", "Build.PL"), 0;
    is system('./Build'), 0;

    ok !-e 'lib/Some/Project/Mite.pm';
    ok !-e 'lib/Some/Project.pm.mite.pm';

    is system('./Build', "clean"), 0;

    chdir $Original_Dir;
};

done_testing;
