use 5.010001;
use strict;
use warnings;

package Mite::App::Command::compile;
use Mite::Miteception;
extends qw(Mite::App::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001010';

##-

sub abstract {
    return "Make your code ready to run";
}

sub execute {
    my ( $self, $opts, $args ) = ( shift, @_ );

    return if $self->should_exit_quietly($opts);

    my $config = Mite::Config->new(
        search_for_mite_dir => $opts->{search_mite_dir}
    );
    my $project = Mite::Project->new(
        config => $config
    );
    Mite::Project->set_default( $project );

    $project->add_mite_shim;
    $project->load_directory;
    $project->write_mites;

    return;
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
