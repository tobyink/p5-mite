use 5.010001;
use strict;
use warnings;

package Mite::Compiled;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010002';

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
