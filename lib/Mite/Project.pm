use 5.010001;
use strict;
use warnings;

package Mite::Project;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.006008';

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

has _limited_parsing =>
  is            => rw,
  isa           => Bool,
  default       => false;

has _module_fakeout_namespace =>
  is            => rw,
  isa           => Str | Undef;

has debug =>
  is            => rw,
  isa           => Bool,
  default       => false;

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

my $parse_mm_args = sub {
    my $coderef = pop;
    my $names   = [ map { ref($_) eq 'ARRAY' ? @$_ : $_ } @_ ];
    ( $names, $coderef );
};

# This is the shim Mite.pm uses when compiling.
sub inject_mite_functions {
    state $sig = sig_named(
        { head => [ Object ], named_to_list => true },
        package   => Any,
        file      => Any,
        kind      => Str,        { default => 'class' },
        arg       => HashRef,    { default => {}      },
        shim      => Str,
        x_source  => Optional[Object],
        x_pkg     => Optional[Object],
    );
    my ( $self, $package, $file, $kind, $arg, $shim, $source, $pkg, $moresubs ) = &$sig;
    my $requested = sub { $arg->{$_[0]} ? 1 : $arg->{'!'.$_[0]} ? 0 : $arg->{'-all'} ? 1 : $_[1]; };

    my $fake_ns = $self->can('_module_fakeout_namespace') && $self->_module_fakeout_namespace;
    if ( defined( $fake_ns ) and not $package =~ /^\Q$fake_ns/ ) {
        $package = "$fake_ns\::$package";
    }

    warn "Gather: $package\n" if $self->debug;

    $source //= $self->source_for(
        Path::Tiny::path( $ENV{MITE_LIMITED_PARSING} // $file )
    );
    $pkg    //= $source->class_for(
        $package,
        $kind eq 'role' ? 'Mite::Role' : 'Mite::Class',
    );
    $pkg->shim_name( $shim );

    no strict 'refs';
    ${ $package .'::USES_MITE' } = ref( $pkg );
    ${ $package .'::MITE_SHIM' } = ref( $shim );

    my $has = sub {
        my $names = shift;
        if ( @_ % 2 ) {
            my $default = shift;
            unshift @_, ( 'CODE' eq ref( $default ) )
                ? ( is => lazy, builder => $default )
                : ( is => ro, default => $default );
        }
        my %spec = @_;

        for my $name ( ref($names) ? @$names : $names ) {
           if( my $is_extension = $name =~ s{^\+}{} ) {
               $pkg->extend_attribute(
                   class   => $pkg,
                   name    => $name,
                   %spec
               );
           }
           else {
               require Mite::Attribute;
               my $attribute = Mite::Attribute->new(
                   class   => $pkg,
                   name    => $name,
                   %spec
               );
               $pkg->add_attribute($attribute);
           }
        }

        return;
    };

    *{ $package .'::has' } = $has
        if $requested->( 'has', 1 );

    *{"$package\::param"} = sub {
        my ( $names, %spec ) = @_;
        $spec{is} = ro unless exists $spec{is};
        $spec{required} = true unless exists $spec{required};
        $has->( $names, %spec );
    } if $requested->( param => 0 );

    *{"$package\::field"} = sub {
        my ( $names, %spec ) = @_;
        $spec{is} ||= ( $spec{builder} || exists $spec{default} ) ? lazy : rwp;
        $spec{init_arg} = undef unless exists $spec{init_arg};
        if ( defined $spec{init_arg} and $spec{init_arg} !~ /^_/ ) {
            croak "A defined 'field.init_arg' must begin with an underscore: %s ", $spec{init_arg};
        }
        $has->( $names, %spec );
    } if $requested->( field => 0 );

    *{ $package .'::with' } = sub {
        $pkg->add_roles_by_name(
            defined( $fake_ns )
                ? ( map "$fake_ns\::$_", @_ )
                : @_
        );
        return;
    } if $requested->( 'with', 1 );

    *{ $package .'::extends' } = sub {
        $pkg->superclasses(
            defined( $fake_ns )
                ? [ map "$fake_ns\::$_", @_ ]
                : [ @_ ]
        );
        return;
    } if $kind eq 'class' && $requested->( 'extends', 1 );

    *{ $package .'::requires' } = sub {
        $pkg->add_required_methods( @_ );
        return;
    } if $kind eq 'role' && $requested->( 'requires', 1 );

    for my $modifier ( qw( before after around ) ) {
        *{ $package .'::'. $modifier } = sub {
            my ( $names, $coderef ) = &$parse_mm_args;
            CodeRef->check( $coderef )
                or croak "Expected a coderef method modifier";
            ArrayRef->of(Str)->check( $names ) && @$names
                or croak "Expected a list of method names to modify";
            $pkg->add_required_methods( @$names );
            return;
        } if $requested->( $modifier, 1 );
    }

    my $want_bool = $requested->( '-bool', 0 );
    my $want_is   = $requested->( '-is',   0 );
    for my $f ( qw/ true false / ) {
        next unless $requested->( $f, $want_bool );
        *{"$package\::$f"} = \&{"$shim\::$f"};
        $pkg->imported_functions->{$f} = "$shim\::$f";
    }
    for my $f ( qw/ ro rw rwp lazy bare / ) {
        next unless $requested->( $f, $want_is );
        *{"$package\::$f"} = \&{"$shim\::$f"};
        $pkg->imported_functions->{$f} = "$shim\::$f";
    }
    for my $f ( qw/ carp croak confess guard / ) {
        next unless $requested->( $f, false );
        *{"$package\::$f"} = \&{"$shim\::$f"};
        $pkg->imported_functions->{$f} = "$shim\::$f";
    }
    if ( $requested->( blessed => false ) ) {
        require Scalar::Util;
        *{"$package\::blessed"} = \&Scalar::Util::blessed;
        $pkg->imported_functions->{blessed} = "Scalar::Util::blessed";
    }

    if ( our %MORE_SUBS ) {
        no warnings 'redefine';
        for my $f ( keys %MORE_SUBS ) {
            *{"$package\::$f"} = $MORE_SUBS{$f};
        }
    }
}

sub write_mites {
    my $self = shift;

    for my $source (values %{$self->sources}) {
        warn "Write mite: ${\ $source->compiled->file }\n" if $self->debug;
        $source->compiled->write(
            module_fakeout_namespace => $self->_module_fakeout_namespace,
        );
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
        $self->_load_file( $file, $inc_dir );
    }

    return;
}

sub _load_file {
    my ( $self, $file, $inc_dir ) = @_;

    warn "Load module: $file\n" if $self->debug;

    $file = Path::Tiny::path($file);

    if ( $self->_limited_parsing ) {
        my $code = $file->slurp;
        my ( $head, $tail ) = split '##-', $code;

        if ( defined $self->_module_fakeout_namespace ) {
            my $ns = $self->_module_fakeout_namespace;
            $head =~ s/package /package $ns\::/;
        }

        do {
            local $@;
            local $ENV{MITE_LIMITED_PARSING} = "$file";
            eval("$head; 1") or do die($@);
        };

        return;
    }

    my $pm_file = $file->relative($inc_dir);
    require $pm_file;

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
        warn "Clean mite: $file\n" if $self->debug;
        Path::Tiny::path($file)->remove;
    }

    return;
}

sub clean_shim {
    my $self = shift;
    warn "Clean shim: ${\ $self->_project_shim_file }\n" if $self->debug;
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

    warn "Init\n" if $self->debug;

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

    warn "Write shim: $shim_file\n" if $self->debug;

    my $shim_package = $self->config->data->{shim};
    return $shim_file if $shim_package eq 'Mite::Shim';

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

Mite::Project - a whole project

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
