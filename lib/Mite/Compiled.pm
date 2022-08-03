use 5.010001;
use strict;
use warnings;

package Mite::Compiled;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.008001';

use Path::Tiny;

# Don't load Mite::Source else it will go circular

has file =>
  is            => rw,
  isa           => Path,
  coerce        => true,
  lazy          => true,
  default       => sub {
      my $self = shift;
      return $self->_source_file2compiled_file( $self->source->file );
  };

has source =>
  is            => ro,
  isa           => MiteSource,
  # avoid a circular dep with Mite::Source
  weak_ref      => true,
  required      => true,
  handles       => [ qw( classes class_order ) ];

sub compile {
    my $self = shift;

    my $code;
    for my $class_name ( @{ $self->class_order } ) {
        my $class = $self->classes->{$class_name};

        # Only supported by Type::Tiny 1.013_001 but no harm
        # in doing this anyway.
        local $Type::Tiny::SafePackage = sprintf 'package %s;',
            eval { $self->source->project->config->data->{shim} }
            // do { $class_name . '::__SAFE_NAMESPACE__' };

        $code .= $class->compile;
    }

    my $tidied;
    eval {
        my $flag;
        if ( $self->source->project->config->should_tidy ) {
            $flag = Perl::Tidy::perltidy(
                source      => \$code,
                destination => \$tidied,
                argv        => [],
            );
        }
        !$flag;
    } and defined($tidied) and length($tidied) and ($code = $tidied);

    return $code;
}

sub write {
    my ( $self, %opts ) = @_;

    my $code = $self->compile;
    if ( defined $opts{module_fakeout_namespace} ) {
        my $ns = $opts{module_fakeout_namespace};
        $code =~ s/$ns\:://g;
    }

    return $self->file->spew_utf8($code);
}

sub remove {
    my $self = shift;

    return $self->file->remove;
}

signature_for _source_file2compiled_file => (
   pos => [ Defined ],
);

sub _source_file2compiled_file {
    my ( $self, $source_file ) = @_;

    # Changes here must be coordinated with Mite.pm
    return $source_file . '.mite.pm';
}

1;

__END__

=pod

=head1 NAME

Mite::Compiled - the extra compiled module file written by Mite

=head1 SYNOPSIS

    use Mite::Compiled;
    my $compiled = Mite::Compiled->new( source => $source );

=head1 DESCRIPTION

NO USER SERVICABLE PARTS INSIDE.  This is a private class.

Represents the extra file written by Mite containing the compiled code.

There is a one-to-one mapping between a source file and a compiled
file, but there can be many Mite classes in one file.  Mite::Compiled
manages the compliation and ensures classes don't write over each
other.

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
