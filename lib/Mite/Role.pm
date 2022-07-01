use 5.010001;
use strict;
use warnings;

package Mite::Role;
use Mite::Miteception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001013';

use Path::Tiny;
use mro;

BEGIN {
    *_CONSTANTS_DEFLATE = "$]" >= 5.012 && "$]" < 5.020 ? sub(){1} : sub(){0};
};

has attributes =>
  is            => ro,
  isa           => HashRef[InstanceOf['Mite::Attribute']],
  default       => sub { {} };

has name =>
  is            => ro,
  isa           => Str,
  required      => true;

has source =>
  is            => rw,
  isa           => InstanceOf['Mite::Source'],
  # avoid a circular dep with Mite::Source
  weak_ref      => true;

has method_modifiers =>
  is            => ro,
  isa           => ArrayRef,
  builder       => sub { [] };

has roles =>
  is            => ro,
  isa           => ArrayRef,
  builder       => sub { [] };

##-

sub _all_subs {
    my $self = shift;
    my $package = $self->name;
    no strict 'refs';
    my $stash = \%{"$package\::"};
    return {
        map {;
          # this is an ugly hack to populate the scalar slot of any globs, to
          # prevent perl from converting constants back into scalar refs in the
          # stash when they are used (perl 5.12 - 5.18). scalar slots on their own
          # aren't detectable through pure perl, so this seems like an acceptable
          # compromise.
          ${"${package}::${_}"} = ${"${package}::${_}"}
            if _CONSTANTS_DEFLATE;
          $_ => \&{"${package}::${_}"}
        }
        grep exists &{"${package}::${_}"},
        grep !/::\z/,
        keys %$stash
    };
}

sub _native_methods {
    my $self = shift;
    my %methods = %{ $self->_all_subs };

    require B;
    for my $name ( sort keys %methods ) {
        my $cv        = B::svref_2object( $methods{$name} );
        my $stashname = eval { $cv->GV->STASH->NAME };
        $stashname eq $self->name
            or $stashname eq 'constant'
            or delete $methods{$name};
    }

    return \%methods;
}

sub methods_to_import_from_roles {
    my $self = shift;

    my %methods;
    for my $role ( @{ $self->roles } ) {
        my %exported = %{ $role->methods_to_export };
        for my $name ( sort keys %exported ) {
            if ( defined $methods{$name} and  $methods{$name} ne $exported{$name} ) {
                require Carp;
                Carp::croak "Conflict between %s and %s; %s must implement %s\n",
                    $methods{$name}, $exported{$name}, $self->name, $name;
            }
            else {
                $methods{$name} = $exported{$name};
            }
        }
    }

    # This package provides a native version of these
    # methods, so don't import.
    my %native = %{ $self->_native_methods };
    for my $name ( keys %native ) {
        delete $methods{$name};
    }

    return \%methods;
}

sub methods_to_export {
    my $self = shift;

    my %methods = %{ $self->methods_to_import_from_roles };
    my %native  = %{ $self->_native_methods };
    my $package = $self->name;

    for my $name ( keys %native ) {
        $methods{$name} = "$package\::$name";
    }

    return \%methods;
}

sub project {
    my $self = shift;

    return $self->source->project;
}

sub add_method_modifier {
    my ( $self, $type, $names, $coderef ) = @_;
    push @{ $self->method_modifiers }, [ $type, $names, $coderef ];
    return;
}

sub add_attributes {
    state $sig = sig_pos( Object, slurpy ArrayRef[InstanceOf['Mite::Attribute']] );
    my ( $self, $attributes ) = &$sig;

    for my $attribute (@$attributes) {
        $self->attributes->{ $attribute->name } = $attribute;
    }

    return;
}

sub add_attribute {
    shift->add_attributes( @_ );
}

sub extend_attribute {
    my ($self, %attr_args) = ( shift, @_ );

    my $name = delete $attr_args{name};

    my $attr = $self->attributes->{$name};
    croak(sprintf <<'ERROR', $name, $self->name) unless $attr;
Could not find an attribute by the name of '%s' to extend in %s
ERROR

    if ( ref $attr_args{default} ) {
        $attr_args{_class_for_default} = $self;
    }

    $self->attributes->{$name} = $attr->clone(%attr_args);

    return;
}

sub add_role {
    my ( $self, $role ) = @_;

    $self->add_attributes( values %{ $role->attributes } );
    push @{ $self->roles }, $role;

    return;
}

sub add_roles_by_name {
    my ( $self, @names ) = @_;

    for my $name ( @names ) {
        my $role = $self->_get_role( $name );
        $self->add_role( $role );
    }

    return;
}

sub _get_role {
    my ( $self, $role_name ) = ( shift, @_ );

    my $project = $self->project;

    # See if it's already loaded
    my $role = $project->class($role_name);
    return $role if $role;

    # If not, try to load it
    require $role_name;
    $role = $project->class($role_name, 'Mite::Role');
    return $role if $role;

    croak <<"ERROR";
$role_name loaded but is not a Mite role.
Composing non-Mite roles not yet supported.
Sorry.
ERROR
}

sub compilation_stages {
    return qw(
        _compile_package
        _compile_uses_mite
        _compile_pragmas
        _compile_composed_methods
    );
}

sub compile {
    my $self = shift;

    my $code = join "\n",
        '{',
        map( $self->$_, $self->compilation_stages ),
        '1;',
        '}';

    #::diag $code if main->can('diag');
    return $code;
}

sub _compile_composed_methods {
    my $self = shift;
    my $code = '';

    my %methods = %{ $self->methods_to_import_from_roles };
    keys %methods or return;

    $code .= "# Methods from roles\n";
    for my $name ( sort keys %methods ) {
        $code .= sprintf '*%s = \&%s;' . "\n", $name, $methods{$name};
    }

    return $code;
}

sub _compile_package {
    my $self = shift;

    return "package @{[ $self->name ]};";
}

sub _compile_uses_mite {
    my $self = shift;

    return sprintf 'our $USES_MITE = q[%s];', ref($self);
}

sub _compile_pragmas {
    my $self = shift;

    return <<'CODE';
use strict;
use warnings;
CODE
}

sub _compile_meta_method {
    return <<'CODE';
sub __META__ {
    no strict 'refs';
    require mro;
    my $class      = shift; $class = ref($class) || $class;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
    };
}
CODE
}

1;
