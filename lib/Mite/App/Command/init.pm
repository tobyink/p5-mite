use 5.010001;
use strict;
use warnings;

package Mite::App::Command::init;
use Mite::Miteception;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001006';

##-

sub usage_desc {
    return "%c init %o <project name>";
}

sub abstract {
    return "Begin using mite with your project";
}

sub validate_args {
    my ( $self, $opts, $args ) = ( shift, @_ );

    $self->usage_error("init needs the name of your project") unless @$args;
}

sub execute {
    my ( $self, $opts, $args ) = ( shift, @_ );

    my $project_name = shift @$args;

    require Mite::Project;
    my $project = Mite::Project->default;
    $project->init_project($project_name);

    say sprintf "Initialized mite in %s", $project->config->mite_dir;

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
