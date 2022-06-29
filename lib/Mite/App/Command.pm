use 5.010001;
use strict;
use warnings;

package Mite::App::Command;
use Mite::Miteception;
extends qw(App::Cmd::Command);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001002';

##-

sub opt_spec {
    my ($class, $app) = (shift, @_);

    return(
      [ "search-mite-dir!" => "only look for .mite/ in the current directory",
        { default => 1 } ],
      [ "exit-if-no-mite-dir!" => "exit quietly if a .mite dir cannot be found",
        { default => 0 } ],
      $class->options($app)
    );
}


sub options {
    my ($class, $app) = (shift, @_);

    return;
}


sub should_exit_quietly {
    my ($self, $opts) = (shift, @_);

    my $config = $self->config;

    return unless $opts->{exit_if_no_mite_dir};
    return 1 if !$opts->{search_mite_dir} && !$config->dir_has_mite(".");
    return 1 if !$config->find_mite_dir;
}


sub project {
    require Mite::Project;
    return Mite::Project->default;
}

sub config {
    my $self = shift;

    return $self->project->config;
}

1;

__END__

=pod

=head1 NAME

Mite::App::Command - glue between Mite and App::Cmd::Command.

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
