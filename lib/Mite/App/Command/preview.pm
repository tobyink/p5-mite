use 5.010001;
use strict;
use warnings;

package Mite::App::Command::preview;
use Mite::Miteception -all;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.009001';

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

    my $project = $self->project;
    $project->load_directory;

    my $file   = $self->kingpin_command->args->get( 'file' )->value;
    my $source = $project->source_for( $file );

    print $source->compile;

    return 0;
}

1;

__END__

=pod

=head1 NAME

Mite::App::Command - provides the "preview" command

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
