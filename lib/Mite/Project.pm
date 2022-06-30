use 5.010001;
use strict;
use warnings;

package Mite::Project;
use Mite::Miteception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001013';

has sources =>
  is            => ro,
  isa           => HashRef[InstanceOf['Mite::Source']],
  default       => sub { {} };

has config =>
  is            => ro,
  isa           => InstanceOf['Mite::Config'],
  lazy          => 1,
  default       => sub {
      require Mite::Config;
      state $config = Mite::Config->new;
      return $config;
  };

##-

use Mite::Source;
use Mite::Class;

sub classes {
    my $self = shift;

    my %classes = map { %{$_->classes} }
                  values %{$self->sources};
    return \%classes;
}

# Careful not to create a class.
sub class {
    my ( $self, $name ) = ( shift, @_ );

    return $self->classes->{$name};
}

# Careful not to create a source.
sub source {
    my ( $self, $file ) = ( shift, @_ );

    return $self->sources->{$file};
}

sub add_sources {
    my ( $self, @sources ) = ( shift, @_ );

    for my $source (@sources) {
        $self->sources->{$source->file} = $source;
    }
}

sub source_for {
    my ( $self, $file ) = ( shift, @_ );

    # Normalize the path.
    $file = Path::Tiny::path($file)->realpath;

    return $self->sources->{$file} ||= Mite::Source->new(
        file    => $file,
        project => $self
    );
}


# This is the shim Mite.pm uses when compiling.
sub inject_mite_functions {
    state $sig = sig_named(
        { head => [ Object ], named_to_list => true },
        package => Any,
        file => Any,
    );
    my ( $self, $package, $file ) = &$sig;

    my $source = $self->source_for($file);
    my $class  = $source->class_for($package);

    no strict 'refs';
    ${ $package .'::USES_MITE' } = 1;

    *{ $package .'::has' } = sub {
        my ( $names, %args ) = @_;
        $names = [$names] unless ref $names;

        for my $name ( @$names ) {
           if( my $is_extension = $name =~ s{^\+}{} ) {
               $class->extend_attribute(
                   class   => $class,
                   name    => $name,
                   %args
               );
           }
           else {
               require Mite::Attribute;
               my $attribute = Mite::Attribute->new(
                   class   => $class,
                   name    => $name,
                   %args
               );
               $class->add_attribute($attribute);
           }
        }

        return;
    };

    *{ $package .'::extends' } = sub {
        my (@classes) = @_;

        $class->superclasses(\@classes);

        return;
    };

    my $parse_args = sub {
        my $coderef = pop;
        my $names   = [ map { ref($_) eq 'ARRAY' ? @$_ : $_ } @_ ];
        ( $names, $coderef );
    };
    *{ $package .'::'. $_ } = sub {
        my ( $names, $coderef ) = &$parse_args;
        require Carp;
        CodeRef->check( $coderef )
            or Carp::croak( "Expected a coderef method modifier" );
        ArrayRef->of(Str)->check( $names ) && @$names
            or Carp::croak( "Expected a list of method names to modify" );
        return;
    } for qw( before after around );

    return;
}

sub write_mites {
    my $self = shift;

    for my $source (values %{$self->sources}) {
        $source->compiled->write;
    }

    return;
}

sub load_files {
    state $sig = sig_pos( 1, ArrayRef, 0 );
    my ( $self, $files, $inc_dir ) = &$sig;

    local $ENV{MITE_COMPILE} = 1;
    local @INC = @INC;
    unshift @INC, $inc_dir if defined $inc_dir;
    for my $file (@$files) {
        my $pm_file = Path::Tiny::path($file)->relative($inc_dir);
        require $pm_file;
    }

    return;
}

sub find_pms {
    my ( $self, $dir ) = ( shift, @_ );
    $dir //= $self->config->data->{source_from};

    return $self->_recurse_directory(
        $dir,
        sub {
            my $path = shift;
            return false if -d $path;
            return false unless $path =~ m{\.pm$};
            return false if $path =~ m{\.mite\.pm$};
            return true;
        }
    );
}

sub load_directory {
    my ( $self, $dir ) = ( shift, @_ );
    $dir //= $self->config->data->{source_from};

    $self->load_files( [$self->find_pms($dir)], $dir );

    return;
}

sub find_mites {
    my ( $self, $dir ) = ( shift, @_ );
    $dir //= $self->config->data->{compiled_to};

    return $self->_recurse_directory(
        $dir,
        sub {
            my $path = shift;
            return false if -d $path;
            return true if $path =~ m{\.mite\.pm$};
            return false;
        }
    );
}

sub clean_mites {
    my ( $self, $dir ) = ( shift, @_ );
    $dir //= $self->config->data->{compiled_to};

    for my $file ($self->find_mites($dir)) {
        Path::Tiny::path($file)->remove;
    }

    return;
}

sub clean_shim {
    my $self = shift;

    return $self->_project_shim_file->remove;
}

# Recursively gather all the pm files in a directory
sub _recurse_directory {
    state $sig = sig_pos( Object, Path, CodeRef );
    my ( $self, $dir, $check ) = &$sig;

    my @pm_files;

    my $iter = $dir->iterator({ recurse => 1, follow_symlinks => 1 });
    while( my $path = $iter->() ) {
        next unless $check->($path);
        push @pm_files, $path;
    }

    return @pm_files;
}

sub init_project {
    my ( $self, $project_name ) = ( shift, @_ );

    $self->config->make_mite_dir;

    $self->write_default_config(
        $project_name
    ) if !-e $self->config->config_file;

    return;
}

sub add_mite_shim {
    my $self = shift;

    my $shim_file = $self->_project_shim_file;
    $shim_file->parent->mkpath;

    my $shim_package = $self->config->data->{shim};
    my $src_shim = $self->_find_mite_shim;
    my $code = $src_shim->slurp;
    $code =~ s/package Mite::Shim;/package $shim_package;/;
    $code =~ s/^Mite::Shim\b/$shim_package/ms;
    $shim_file->spew( $code );

    return $shim_file;
}

sub _project_shim_file {
    my $self = shift;

    my $config = $self->config;
    my $shim_package = $config->data->{shim};
    my $shim_dir     = $config->data->{source_from};

    my $shim_file = $shim_package;
    $shim_file =~ s{::}{/}g;
    $shim_file .= ".pm";
    return Path::Tiny::path($shim_dir, $shim_file);
}

sub _find_mite_shim {
    my $self = shift;

    for my $dir (@INC) {
        # Avoid code refs in @INC
        next if ref $dir;

        my $shim = Path::Tiny::path($dir, "Mite", "Shim.pm");
        return $shim if -e $shim;
    }

    croak <<"ERROR";
Can't locate Mite::Shim in \@INC.  \@INC contains:
@{[ map { "  $_\n" } grep { !ref($_) } @INC ]}
ERROR
}

sub write_default_config {
    my $self = shift;
    my $project_name = Str->(shift);
    my %args = @_;

    my $libdir = Path::Tiny::path('lib');
    $self->config->write_config({
        project         => $project_name,
        shim            => $project_name.'::Mite',
        source_from     => $libdir.'',
        compiled_to     => $libdir.'',
        %args
    });
    return;
}

{
    # Get/set the default for a class
    my %Defaults;
    sub default {
        my $class = shift;
        return $Defaults{$class} ||= $class->new;
    }

    sub set_default {
        my ( $class, $new_default ) = ( shift, @_ );
        $Defaults{$class} = $new_default;
        return;
    }
}

1;

__END__

=pod

=head1 NAME

Mite::Project - Representing a whole project.

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
