use 5.010001;
use strict;
use warnings;

package Mite::App::Command::compile;
use Mite::Miteception -all;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.008002';

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

    if ( $self->config->data->{dogfood} ) {
        $project->_module_fakeout_namespace(
            sprintf 'A%02d::B%02d', int(rand(100)), int(rand(100))
        );
    }

    $project->add_mite_shim;
    $project->load_directory;
    $project->write_mites;
    $project->write_mopper;

    return 0;
}

1;

__END__

=pod

=head1 NAME

Mite::App::Command - provides the "compile" command

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
