use 5.010001;
use strict;
use warnings;

package Mite::App::Command::clean;
use Mite::Miteception -all;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010003';

sub abstract {
    return "Remove compiled mite files.";
}

sub execute {
    my $self = shift;

    return 0 if $self->should_exit_quietly; 

    my $project = $self->project;
    $project->clean_mites;
    $project->clean_shim;

    return 0;
}

1;
