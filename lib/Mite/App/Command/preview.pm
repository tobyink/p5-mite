use 5.010001;
use strict;
use warnings;

package Mite::App::Command::preview;
use Mite::Miteception -all;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010007';

sub abstract {
    return "Preview the .mite.pm for a file.";
}

around _build_kingpin_command => sub {
    my ( $next, $self, @args ) = @_;

    my $command = $self->$next( @args );
    $command->arg( 'file', 'Path to file to preview.' )->required->existing_file;

    return $command;
};

sub execute {
    my $self = shift;

    return 0 if $self->should_exit_quietly;

    my $file = $self->kingpin_command->args->get( 'file' )->value;

    my $project = $self->project;
    $project->load_directory;

    $project->load_files( [ $file ], '.' )
        unless $project->sources->{$file};

    my $source = $project->source_for( $file );
    print $source->compile;

    return 0;
}

1;
