use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasRoles;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010001';

requires qw(
    source
    native_methods
);

has roles =>
  is            => rw,
  isa           => ArrayRef[MiteRole],
  builder       => sub { [] };

has role_args =>
  is            => rw,
  isa           => Map[ NonEmptyStr, HashRef|Undef ],
  builder       => sub { {} };

sub methods_to_import_from_roles {
    my $self = shift;

    my %methods;
    for my $role ( @{ $self->roles } ) {
        my $role_args = $self->role_args->{ $role->name } || {};
        my %exported  = %{ $role->methods_to_export( $role_args ) };
        for my $name ( sort keys %exported ) {
            if ( defined $methods{$name} and  $methods{$name} ne $exported{$name} ) {
                croak "Conflict between %s and %s; %s must implement %s\n",
                    $methods{$name}, $exported{$name}, $self->name, $name;
            }
            else {
                $methods{$name} = $exported{$name};
            }
        }
    }

    # This package provides a native version of these
    # methods, so don't import.
    my %native = %{ $self->native_methods };
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

sub add_role {
    my ( $self, $role ) = @_;

    my @attr = sort { $a->_order <=> $b->_order }
        values %{ $role->attributes };
    for my $attr ( @attr ) {
        $self->add_attribute( $attr )
            unless $self->attributes->{ $attr->name };
    }
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
    eval "require $role_name; 1"
        or do {
            my $file_name = $role_name;
            if ( my $yuck = $project->_module_fakeout_namespace ) {
                $file_name =~ s/$yuck\:://g;
            }
            $file_name =~ s/::/\//g;
            $file_name = "lib/$file_name.pm";
            $project->_load_file( $file_name );
        };
    if ( $INC{'Role/Tiny.pm'} and 'Role::Tiny'->is_role( $role_name ) ) {
        require Mite::Role::Tiny;
        $role = 'Mite::Role::Tiny'->inhale( $role_name );
    }
    else {
        $role = $project->class( $role_name, 'Mite::Role' );
    }
    return $role if $role;

    croak <<"ERROR", $role_name;
%s loaded but is not a recognized role. Mite roles and Role::Tiny
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

sub handle_with_keyword {
    my $self = shift;

    while ( @_ ) {
        my $role = shift;
        my $args = Str->check( $_[0] ) ? undef : shift;
        $self->role_args->{$role} = $args;
        $self->add_roles_by_name( $role );
    }

    return;
}

around compilation_stages => sub {
    my ( $next, $self ) = ( shift, shift );
    my @stages = $self->$next( @_ );
    push @stages, qw(
        _compile_with
        _compile_does
        _compile_composed_methods
    );
    return @stages;
};

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

    my $version_tests = join "\n\t",
        map { sprintf '%s->VERSION( %s );',
            B::perlstring( $_ ),
            B::perlstring( $self->role_args->{$_}{'-version'} )
        }
        grep {
            $self->role_args->{$_}
            and $self->role_args->{$_}{'-version'}
        }
        @$roles;

    my $does_hash = join ", ", map sprintf( "%s => 1", B::perlstring($_) ), $self->does_list;

    return <<"END";
BEGIN {
    $require_list
    $version_tests
    our \%DOES = ( $does_hash );
}
END
}

sub _compile_does {
    my $self = shift;
    return <<'CODE'
# See UNIVERSAL
sub DOES {
    my ( $self, $role ) = @_;
    our %DOES;
    return $DOES{$role} if exists $DOES{$role};
    return 1 if $role eq __PACKAGE__;
    return $self->SUPER::DOES( $role );
}

# Alias for Moose/Moo-compatibility
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

1;
