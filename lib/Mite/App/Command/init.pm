use 5.010001;
use strict;
use warnings;

package Mite::App::Command::init;
use Mite::Miteception -all;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.006001';

##-

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
    $self->project->init_project($project_name);

    printf "Initialized mite in %s\n", $self->config->mite_dir;

    return;
}

1;

__END__

=pod

=head1 NAME

Mite::App::Command - provides the "init" command

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
