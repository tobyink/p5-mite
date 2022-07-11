use 5.010001;
use strict;
use warnings;

package Mite::Config;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.006009';

has mite_dir_name =>
  is            => ro,
  isa           => Str,
  default       => '.mite';

has mite_dir =>
  is            => ro,
  isa           => Path->no_coercions->plus_coercions(Str, 'Path::Tiny::path($_)'),
  coerce        => true,
  lazy          => true,
  default       => sub {
      my $self = shift;
      return $self->find_mite_dir ||
        croak "No @{[$self->mite_dir_name]} directory found.\n";
  };

has config_file =>
  is            => ro,
  isa           => Path->no_coercions->plus_coercions(Str, 'Path::Tiny::path($_)'),
  coerce        => true,
  lazy          => true,
  default       => sub {
      my $self = shift;
      return $self->mite_dir->child("config");
  };

has data =>
  is            => rw,
  isa           => HashRef,
  lazy          => true,
  default       => sub {
      my $self = shift;
      return $self->yaml_load( $self->config_file->slurp_utf8 );
  };

has search_for_mite_dir =>
  is            => rw,
  isa           => Bool,
  default       => true;

##-

sub make_mite_dir {
    my ( $self, $dir ) = ( shift, @_ );
    $dir //= Path::Tiny->cwd;

    return Path::Tiny::path($dir)->child($self->mite_dir_name)->mkpath;
}

sub write_config {
    my ( $self, $data ) = ( shift, @_ );
    $data //= $self->data;

    $self->config_file->spew_utf8( $self->yaml_dump( $data ) );
    return;
}

sub dir_has_mite {
    my ( $self, $dir ) = ( shift, @_ );

    my $maybe_mite = Path::Tiny::path($dir)->child($self->mite_dir_name);
    return $maybe_mite if -d $maybe_mite;
    return;
}

sub find_mite_dir {
    my ( $self, $current ) = ( shift, @_ );
    $current //= Path::Tiny->cwd;

    do {
        my $maybe_mite = $self->dir_has_mite($current);
        return $maybe_mite if $maybe_mite;

        $current = $current->parent;
    } while $self->search_for_mite_dir && !$current->is_rootdir;

    return;
}

sub should_tidy {
    my $self = shift;
    $self->data->{perltidy} && eval { require Perl::Tidy; 1 };
}

sub yaml_load {
    my ( $class, $yaml ) = ( shift, @_ );

    require YAML::XS;
    return YAML::XS::Load($yaml);
}

sub yaml_dump {
    my ( $class, $data ) = ( shift, @_ );

    require YAML::XS;
    return YAML::XS::Dump($data);
}

1;

__END__

=pod

=head1 NAME

Mite::Config - configuration file for a project

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
