use 5.010001;
use strict;
use warnings;

package Mite::App::Command;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.006010';

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

##-

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

__END__

=pod

=head1 NAME

Mite::App::Command - base class for subcommands for bin/mite

=head1 DESCRIPTION

NO USER SERVICABLE PARTS INSIDE.  This is a private class.

=head1 BUGS

Please report any bugs to L<https://github.com/tobyink/p5-mite/issues>.

=head1 AUTHOR

Michael G Schwern E<lt>mschwern@cpan.orgE<gt>.

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011-2014 by Michael G Schwern.

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut
