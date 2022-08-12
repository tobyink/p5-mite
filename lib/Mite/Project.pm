use 5.010001;
use strict;
use warnings;

package Mite::Project;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010002';

has sources =>
  is            => ro,
  isa           => HashRef[MiteSource],
  default       => sub { {} };

has config =>
  is            => ro,
  isa           => MiteConfig,
  lazy          => 1,
  default       => sub {
      require Mite::Config;
      state $config = Mite::Config->new;
      return $config;
  };

has _module_fakeout_namespace =>
  is            => rw,
  isa           => Str | Undef;

has debug =>
  is            => rw,
  isa           => Bool,
  default       => false;

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
signature_for inject_mite_functions => (
    named => [
        package   => Any,
        file      => Any,
        kind      => Optional[Str],
        arg       => HashRef, { default => {} },
        shim      => Str,
        x_source  => Optional[Object],
        x_pkg     => Optional[Object],
    ],
    named_to_list => true,
);

sub inject_mite_functions {
    my ( $self, $package, $file, $kind, $arg, $shim, $source, $pkg ) = @_;
    $kind //= ( $arg->{'-role'} ? 'role' : 'class' );

    my $fake_ns = $self->can('_module_fakeout_namespace') && $self->_module_fakeout_namespace;
    if ( defined( $fake_ns ) and not $package =~ /^\Q$fake_ns/ ) {
        $package = "$fake_ns\::$package";
    }

    warn "Gather: $package\n" if $self->debug;

    $source //= $self->source_for(
        Path::Tiny::path( $ENV{MITE_COMPILE_SELF} // $file )
    );
    $pkg //= $source->class_for(
        $package,
        $kind eq 'role' ? 'Mite::Role' : 'Mite::Class',
    );
    $pkg->shim_name( $shim );
    $pkg->arg( $arg );
    $pkg->inject_mite_functions( $file, $arg );
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

sub _project_mopper_file {
    my $self = shift;

    my ( $mop_package, $mop_dir );
    eval {
        my $config   = $self->config;
        $mop_package = $config->data->{mop};
        $mop_dir     = $config->data->{source_from};

        $mop_package and $mop_dir;
    } or return;

    my $mop_file = $mop_package;
    $mop_file =~ s{::}{/}g;
    $mop_file .= ".pm";
    return Path::Tiny::path($mop_dir, $mop_file);
}

sub write_mopper {
    my $self = shift;

    my $mop_file = $self->_project_mopper_file or return;

    my $dir = Path::Tiny::path( $self->config->data->{source_from} );

    my $code = $self->_compile_mop_header;
    for my $source ( sort { $a->file cmp $b->file } values %{ $self->sources } ) {
        my $relative_name = $source->file->relative($dir);
        $code .= $source->_compile_mop( $relative_name );
    }
    for my $class ( sort { $a->name cmp $b->name } values %{ $self->classes } ) {
        $code .= $class->_compile_mop_postamble;
    }

    if ( my $yuck = $self->_module_fakeout_namespace ) {
        $code =~ s/$yuck\:://g;
    }

    $code .= "\ntrue;\n\n";

    warn "Write MOP: $mop_file\n" if $self->debug;
    $mop_file->spew( $code );

    return;
}

sub _compile_mop_header {
    return sprintf <<'CODE', shift->config->data->{mop};
package %s;

use Moose ();
use Moose::Util ();
use Moose::Util::TypeConstraints ();
use constant { true => !!1, false => !!0 };

CODE
}

signature_for load_files => (
    pos => [ ArrayRef, 0 ],
);

sub load_files {
    my ( $self, $files, $inc_dir ) = @_;

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

    if ( $self->{_already}{$file}++ ) {
        warn "Skipping $file: already loaded\n" if $self->debug;
        return;
    }

    if ( defined $self->_project_mopper_file
    and $file eq $self->_project_mopper_file ) {
        warn "Skipping $file: it's the mop\n" if $self->debug;
        return;
    }

    warn "Load module: $file\n" if $self->debug;

    $file = Path::Tiny::path($file);

    if ( defined $self->_module_fakeout_namespace ) {
        my $ns = $self->_module_fakeout_namespace;

        my $code = $file->slurp;
        $code =~ s/package /package $ns\::/;

        do {
            local $@;
            local $ENV{MITE_COMPILE_SELF} = "$file";
            eval("$code; 1") or do die($@);
        };

        return;
    }

    if ( my $pm_file = eval { $file->relative($inc_dir) } ) {
        require $pm_file;
    }
    else {
        local $@;
        eval( $file->slurp ) or die $@;
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
signature_for _recurse_directory => (
    pos => [ Path, CodeRef ],
);

sub _recurse_directory {
    my ( $self, $dir, $check ) = @_;

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
