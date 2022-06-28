use 5.010001;
use strict;
use warnings;

package Mite::App::Command::clean;
use Mite::Miteception;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001001';

##-

sub abstract {
    return "Remove compiled mite files";
}

sub execute {
    my ( $self, $opts, $args ) = ( shift, @_ );

    return if $self->should_exit_quietly($opts); 

    require Mite::Project;
    my $project = Mite::Project->default;
    $project->clean_mites;
    $project->clean_shim;

    return;
}

1;
