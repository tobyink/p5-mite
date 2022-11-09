use 5.010001;
use strict;
use warnings;

package Mite::MakeMaker;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.011000';

use File::Find;
use autodie;

{
    package # hide from indexer
        MY;

    sub top_targets {
        my $self = shift;

        my $make = $self->SUPER::top_targets;

        # Hacky way to run the mite target before pm_to_blib.
        $make =~ s{(pure_all \s* ::? .*) (pm_to_blib)}{$1 mite $2}x;

        return $make;
    }

    sub postamble {
        my $self = shift;

        my $mite = $ENV{MITE} || 'mite';

        return sprintf <<'MAKE', $mite;
MITE=%s

mite ::
	- $(MITE) compile --exit-if-no-mite-dir --no-search-mite-dir
	- $(ABSPERLRUN) -MMite::MakeMaker -e 'Mite::MakeMaker->fix_pm_to_blib(@ARGV);' lib $(INST_LIB)

clean ::
	- $(MITE) clean --exit-if-no-mite-dir --no-search-mite-dir

MAKE
    }
}

signature_for fix_pm_to_blib => (
    pos => [ Path, Path ],
);

sub fix_pm_to_blib {
    my ( $self, $from_dir, $to_dir ) = @_;

    find({
        wanted => sub {
            # Not just the mite files, but also the mite shim.
            return if -d $_ || !m{\.pm$};

            my $src = Path::Tiny::path($File::Find::name);
            my $dst = change_parent_dir($from_dir, $to_dir, $src);

            say "Copying $src to $dst";

            $dst->parent->mkpath;
            $src->copy($dst);

            return;
        },
        no_chdir => 1
    }, $from_dir);

    return;
}

signature_for change_parent_dir => (
    method => false,
    pos => [ Path, Path, Path ],
);

sub change_parent_dir {
    my ( $old_parent, $new_parent, $file ) = @_;

    return $new_parent->child( $file->relative($old_parent) );
}

1;

__END__

=head1 NAME

Mite::MakeMaker - use in your Makefile.PL when developing with Mite

=head1 SYNOPSIS

    # In Makefile.PL
    use ExtUtils::MakeMaker;
    eval { require Mite::MakeMaker; };

    WriteMakefile(
        ...as normal...
    );

=head1 DESCRIPTION

If your module is being developed with L<ExtUtils::MakeMaker>, this
module makes working with L<Mite> more natural.

Be sure to C<require> this in an C<eval> block so users can install
your module without mite.

=head3 C<make>

When C<make> is run, mite will compile any changes.

=head3 C<make clean>

When C<make clean> is run, mite files will be cleaned up as well.

=head3 C<make manifest>

Be sure to run this after running C<make> and before running C<make
dist> so all the mite files are picked up.

=head3 F<MANIFEST.SKIP>

The F<.mite> directory should not be shipped with your distribution.
Add C<^\.mite/> to your F<MANIFEST.SKIP> file.

=head1 BUGS

Please report any bugs to L<https://github.com/tobyink/p5-mite/issues>.

=head1 SEE ALSO

L<Mite::ModuleBuild>

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
