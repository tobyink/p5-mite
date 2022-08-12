use 5.010001;
use strict;
use warnings;

package Mite::App::Command::init;
use Mite::Miteception -all;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010003';

sub abstract {
    return "Begin using mite with your project.";
}

around _build_kingpin_command => sub {
    my ( $next, $self, @args ) = @_;

    my $command = $self->$next( @args );
    $command->arg( 'project', 'Project name.' )->required->string;

    return $command;
};

sub execute {
    my $self = shift;

    my $project_name = $self->kingpin_command->args->get( 'project' );
    $self->project->init_project( $project_name->value );

    printf "Initialized mite in %s\n", $self->config->mite_dir;

    return 0;
}

1;
