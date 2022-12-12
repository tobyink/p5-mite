use 5.010001;
use strict;
use warnings;

package Mite::App::Command;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.012000';

has app => (
    is => ro,
    isa => Object,
    required => true,
    weak_ref => true,
    handles => [ 'config', 'project', 'kingpin' ],
);

has kingpin_command => (
    is => lazy,
    isa => Object,
);

sub command_name {
   my $self = shift;
   my $class = ref($self) || $self;

   my ( $part ) = ( $class =~ /::(\w+)$/ );

   return $part;
}

sub abstract {
    return '???';
}

sub BUILD {
    my ( $self, $app ) = @_;

    my $name = $self->command_name;
    $self->app->commands->{$name} = $self;

    $self->kingpin_command; # force build

    return;
}

sub _build_kingpin_command {
    my ( $self ) = @_;

    return $self->kingpin->command( $self->command_name, $self->abstract );
}

sub should_exit_quietly {
    my $self = shift;

    my $config = $self->config;

    return false
        unless $self->app->get_flag_value( 'exit-if-no-mite-dir' );

    return true
        if !$self->app->get_flag_value( 'search-mite-dir' )
        && !$config->dir_has_mite(".");

    return true
        if !$config->find_mite_dir;

    return false;
}

1;
