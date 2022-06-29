use 5.010001;
use strict;
use warnings;

package Mite::ModuleBuild;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001008';

use parent 'Module::Build';

sub _mite {
    my $self = shift;

    return $ENV{MITE} || 'mite';
}

sub ACTION_code {
    my $self = shift;

    system $self->_mite. " compile --exit-if-no-mite-dir --no-search-mite-dir";

    return $self->SUPER::ACTION_code;
}

sub ACTION_clean {
    my $self = shift;

    system $self->_mite. " clean --exit-if-no-mite-dir --no-search-mite-dir";

    return $self->SUPER::ACTION_clean;
}

# This allows users to write
# my $class = eval { require Mite::ModuleBuild } || 'Module::Build';
return __PACKAGE__;

__END__

=head1 NAME

Mite::ModuleBuild - Use in your Build.PL when developing with Mite

=head1 SYNOPSIS

    # In Build.PL
    use Module::Build;
    my $class = eval { require Mite::ModuleBuild } || 'Module::Build';

    my $build = $class->new(
        ...as normal...
    );
    $build->create_build_script;

=head1 DESCRIPTION

If your module is being developed with L<Module::Build>, this
module makes working with L<Mite> more natural.

Be sure to C<require> this in an C<eval> block so users can install
your module without mite.  C<require> will return the name of the
class.

=head3 C<./Build>

When C<./Build> is run, mite will compile any changes.

=head3 C<./Build clean>

When C<./Build clean> is run, mite files will be cleaned up as well.

=head3 C<./Build manifest>

Be sure to run this after running C<./Build> and before running
C<./Build dist> so all the mite files are picked up.

=head3 F<MANIFEST.SKIP>

The F<.mite> directory should not be shipped with your distribution.
Add C<^\.mite/> to your F<MANIFEST.SKIP> file.

=head1 SEE ALSO

L<Mite::MakeMaker>

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
