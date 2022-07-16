use 5.010001;
use strict;
use warnings;

package Mite::App;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.007000';

has commands => (
    is => ro,
    isa => HashRef[Object],
    default => \ '{}',
);

has kingpin => (
    is => lazy,
    isa => Object,
    handles => {
        _parse_argv => 'parse',
    },
);

has project => (
    is => lazy,
    isa => MiteProject,
    handles => [ 'config' ],
);

##-

use Module::Pluggable
    search_path => [ 'Mite::App::Command' ],
    sub_name    => '_plugins',
    require     => true,
    inner       => false,
    on_require_error => sub {
        my ( $plugin, $err ) = @_;
        return if $plugin =~ /.mite$/;
        croak $err;
    };

sub BUILD {
    my $self = shift;
    for my $plugin ( $self->_plugins ) {
        $plugin->new( app => $self );
    }
}

sub _default_command {
    return 'compile';
}

sub _build_kingpin {
    require Getopt::Kingpin;

    my $kingpin = Getopt::Kingpin->new;
    $kingpin->flags->get( 'help' )->short( 'h' );
    $kingpin->flag( 'verbose', 'Verbose mode.' )->short( 'v' )->bool;
    $kingpin->flag( 'search-mite-dir', 'Only look for .mite/ in the current directory.' )->bool->default( true );
    $kingpin->flag( 'exit-if-no-mite-dir', 'Exit quietly if .mite/ cannot be found.' )->bool->default( false );
    $kingpin->flag( 'set', 'Set config option.' )->string_hash;

    return $kingpin;
}

sub _build_project {
    require Mite::Project;
    return Mite::Project->default;
}

sub get_flag_value {
    my ( $self, $flag ) = @_;
    my $got = $self->kingpin->flags->get( $flag );
    $got ? $got->value : undef;
}

sub run {
    my ( $class, $argv ) = @_;

    my $self = $class->new;
    my $parsed = $self->_parse_argv( $argv || [ @ARGV ] );

    $self->project->debug( $self->get_flag_value( 'verbose' ) );
    $self->config->search_for_mite_dir( $self->get_flag_value( 'search-mite-dir' ) );

    {
        my $set_flag = $self->kingpin->flags->get( 'set' );
        my %set = %{ $set_flag->value || {} };
        for my $opt ( keys %set ) {
            $self->config->data->{$opt} = $set{$opt};
        }
    }

    my $command = $parsed->isa( 'Getopt::Kingpin::Command' )
        ? $self->commands->{ $parsed->name }
        : $self->commands->{ $self->_default_command };

    return $command->execute;
}

1;

__END__

=pod

=head1 NAME

Mite::App - guts for bin/mite

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
