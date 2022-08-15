use 5.010001;
use strict;
use warnings;

package Mite::App::Command::exec;
use Mite::Miteception -all;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010007';

sub abstract {
    return "Compile the project in memory and run a script.";
}

around _build_kingpin_command => sub {
    my ( $next, $self, @args ) = @_;

    my $command = $self->$next( @args );
    $command->flag( 'oneliner', 'Script is a oneliner, not a filename.' )->short( 'e' )->bool;
    $command->arg( 'script', 'Script to run.' )->file;
    $command->arg( 'args', 'Arguments to pass to script.' )->string_list;

    return $command;
};

sub execute {
    my $self = shift;

    return 0 if $self->should_exit_quietly;

    my $oneliner = $self->kingpin_command->flags->get( 'oneliner' )->value;
    my $script   = $self->kingpin_command->args->get( 'script' )->value;
    my $args     = $self->kingpin_command->args->get( 'args' )->value;

    unless ( defined $script ) {
        printf STDERR "%s: error: expected oneliner or script, try --help\n",
            $self->kingpin_command->parent->name;
        return 1;
    }

    my $project = $self->project;
    $project->load_directory;

    for my $source ( values %{ $project->sources } ) {
        local $@;
        eval( $source->compile ) or die $@;
    }

    {
        local @ARGV = @{ $args || [] };
        if ( $oneliner ) {
            local $@;
            my $r = eval "$script; 1";
            if ( $r ) {
                return 0;
            }
            else {
                warn "$@\n";
                return 1;
            }
        }
        else {
            if ( not $script->exists ) {
                printf STDERR "%s: error: %s does not exist, try --help\n",
                    $self->kingpin_command->parent->name, $script;
                return 1;
            }
            local $@;
            do $script;
            if ( $@ ) {
                warn "$@\n";
                return 1;
            }
            return 0;
        }
    }

    return 0;
}

1;
