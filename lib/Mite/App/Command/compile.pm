use 5.010001;
use strict;
use warnings;

package Mite::App::Command::compile;
use Mite::Miteception -all;
extends 'Mite::App::Command' => { -version => '0.009000' };

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010003';

sub abstract {
    return "Make your code ready to run.";
}

sub execute {
    my $self = shift;

    require Mite::Attribute;
    require Mite::Class;
    require Mite::Config;
    require Mite::Project;
    require Mite::Role;
    require Mite::Role::Tiny;
    require Mite::Signature;

    return 0 if $self->should_exit_quietly;

    my $project = $self->project;

    # This is a hack to force Mite::* modules which are already loaded
    # to be loaded again so Mite can compile itself.
    #
    if ( $self->config->data->{dogfood} ) {
        $project->_module_fakeout_namespace(
            sprintf 'A%02d::B%02d', int(rand 100), int(rand 100)
        );
    }

    $project->add_mite_shim;
    $project->load_directory;
    $project->write_mites;
    $project->write_mopper;

    return 0;
}

1;
