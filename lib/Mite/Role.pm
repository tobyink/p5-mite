use 5.010001;
use strict;
use warnings;

package Mite::Role;
use Mite::Miteception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.003001';

use Path::Tiny;
use B ();

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

has roles =>
  is            => ro,
  isa           => ArrayRef,
  builder       => sub { [] };

has constants =>
  is            => ro,
  isa           => HashRef,
  builder       => sub { {} };

##-

sub skip_compiling {
    return false;
}

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

    # Never propagate
    delete $methods{$_} for qw(
        new
        DESTROY
        DOES
        does
        __META__
        __FINALIZE_APPLICATION__
    );

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
    eval "require $role_name;";
    if ( $INC{'Role/Tiny.pm'} and 'Role::Tiny'->is_role( $role_name ) ) {
        require Mite::Role::Tiny;
        $role = 'Mite::Role::Tiny'->inhale( $role_name );
    }
    else {
        $role = $project->class( $role_name, 'Mite::Role' );
    }
    return $role if $role;

    croak <<"ERROR";
$role_name loaded but is not a recognized role. Mite roles and Role::Tiny
roles are the only supported roles. Sorry.
ERROR
}

sub does_list {
    my $self = shift;
    return (
        $self->name,
        map( $_->does_list, @{ $self->roles } ),
    );
}

sub compilation_stages {
    return qw(
        _compile_package
        _compile_uses_mite
        _compile_pragmas
        _compile_constants
        _compile_with
        _compile_does
        _compile_composed_methods
        _compile_callback
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

sub _compile_with {
    my $self = shift;

    my $roles = [ map $_->name, @{ $self->roles } ];
    return unless @$roles;

    my $source = $self->source;

    my $require_list = join "\n\t",
                            map  { "require $_;" }
                            # Don't require a role from the same source
                            grep { !$source || !$source->has_class($_) }
                            @$roles;

    my $does_hash = join ", ", map sprintf( "%s => 1", B::perlstring($_) ), $self->does_list;

    return <<"END";
BEGIN {
    $require_list
    our \%DOES = ( $does_hash );
}
END
}

sub _compile_does {
    my $self = shift;
    return <<'CODE'
sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    return $self->SUPER::DOES( $role );
}

sub does {
    shift->DOES( @_ );
}
CODE
}

sub _compile_composed_methods {
    my $self = shift;
    my $code = '';

    my %methods = %{ $self->methods_to_import_from_roles };
    keys %methods or return;

    $code .= "# Methods from roles\n";
    for my $name ( sort keys %methods ) {
        # Use goto to help namespace::autoclean recognize these as
        # not being imported methods.
        $code .= sprintf 'sub %s { goto \&%s; }' . "\n", $name, $methods{$name};
    }

    return $code;
}

sub _compile_constants {
    my $self = shift;
    my %const = %{ $self->constants }
        or return;

    return join "\n",
        'BEGIN {',
        map(
            sprintf( '    *%s = \&%s;',  $_, $const{$_} ),
            sort keys %const
        ),
        '};',
        '';
}

sub _compile_package {
    my $self = shift;

    return "package @{[ $self->name ]};";
}

sub _compile_uses_mite {
    my $self = shift;

    return sprintf 'our $USES_MITE = %s;', B::perlstring( ref($self) );
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

sub _compile_callback {
    my $self = shift;

    my $role_list = join q[, ], map B::perlstring( $_->name ), @{ $self->roles };
    my $shim = B::perlstring( eval { $self->project->config->data->{shim} } || 'Mite::Shim' );

    return sprintf <<'CODE', $role_list, $shim;
# Callback which classes consuming this role will call
sub __FINALIZE_APPLICATION__ {
    my ( $me, $target, $args ) = @_;
    our ( %%CONSUMERS, @METHOD_MODIFIERS );

    # Ensure a given target only consumes this role once.
    if ( exists $CONSUMERS{$target} ) {
        return;
    }
    $CONSUMERS{$target} = 1;

    my $type = do { no strict 'refs'; ${"$target\::USES_MITE"} };
    if ( $type ne 'Mite::Class' ) {
        return;
    }

    my @roles = ( %s );
    my %%nextargs = %%{ $args || {} };
    ( $nextargs{-indirect} ||= 0 )++;
    die "PANIC!" if $nextargs{-indirect} > 100;
    for my $role ( @roles ) {
        $role->__FINALIZE_APPLICATION__( $target, { %%nextargs } );
    }

    my $shim = %s;
    for my $modifier_rule ( @METHOD_MODIFIERS ) {
        my ( $modification, $names, $coderef ) = @$modifier_rule;
        $shim->$modification( $target, $names, $coderef );
    }

    return;
}
CODE
}

1;

__END__

=pod

=head1 NAME

Mite::Role - Representing a role within a project.

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
