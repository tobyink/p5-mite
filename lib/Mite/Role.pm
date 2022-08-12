use 5.010001;
use strict;
use warnings;

package Mite::Role;
use Mite::Miteception -all;
extends qw(
    Mite::Package
);
with qw(
    Mite::Trait::HasRequiredMethods
    Mite::Trait::HasAttributes
    Mite::Trait::HasRoles
    Mite::Trait::HasMethods
    Mite::Trait::HasMOP
);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010003';

use Path::Tiny;
use B ();

sub kind { 'role' }

sub methods_to_export {
    my ( $self, $role_args ) = @_;

    my %methods = %{ $self->methods_to_import_from_roles };
    my %native  = %{ $self->native_methods };
    my $package = $self->name;

    for my $name ( keys %native ) {
        $methods{$name} = "$package\::$name";
    }

    if ( my $excludes = $role_args->{'-excludes'} ) {
        for my $excluded ( ref( $excludes ) ? @$excludes : $excludes ) {
            delete $methods{$excluded};
        }
    }

    if ( my $alias = $role_args->{'-alias'} ) {
        for my $oldname ( sort keys %$alias ) {
            my $newname = $alias->{$oldname};
            $methods{$newname} = delete $methods{$oldname};
        }
    }

    return \%methods;
}

sub accessors_to_export {
    my $self = shift;
    return {} unless $self->arg->{'-runtime'};

    my @accessors = map $_->associated_methods,
        sort { $a->_order <=> $b->_order }
        values %{ $self->attributes };

    return { map { $_ => $self->name . "::$_"; } @accessors };
}

around compilation_stages => sub {
    my ( $next, $self ) = ( shift, shift );
    my @stages = $self->$next( @_ );
    push @stages, qw(
        _compile_callback
    );
    push @stages, '_compile_runtime_application'
        if $self->arg->{'-runtime'};
    return @stages;
};

sub _compile_runtime_application {
    my $self = shift;
    my $name = $self->name;

    my $methods = {
        %{ $self->methods_to_export },
        %{ $self->accessors_to_export },
    };
    my $method_hash = join qq{,\n},
        map sprintf(
            '        %s => %s',
            B::perlstring( $_ ),
            B::perlstring( $methods->{$_} =~ /^\Q$name\E::(\w+)$/ ? $1 : $methods->{$_} )
        ),
        sort keys %$methods;

    return sprintf <<'CODE', $method_hash;
{
    our ( %%METHODS ) = (
%s
    );

    my %%DONE;
    sub APPLY_TO {
        my $to = shift;
        if ( ref $to ) {
            my $new_class = CREATE_CLASS( ref $to );
            return bless( $to, $new_class );
        }
        return if $DONE{$to};
        {
            no strict 'refs';
            ${"$to\::USES_MITE"} = 'Mite::Class';
            for my $method ( keys %%METHODS ) {
                $to->can($method) or *{"$to\::$method"} = \&{ $METHODS{$method} };
            }
            for ( "DOES", "does" ) {
                $to->can( $_ ) or *{"$to\::$_"} = sub { shift->isa( @_ ) };
            }
        }
        __PACKAGE__->__FINALIZE_APPLICATION__( $to );
        $MITE_SHIM->HANDLE_around( $to, "class", [ "DOES", "does" ], sub {
            my ( $next, $self, $role ) = @_;
            return 1 if $role eq __PACKAGE__;
            return 1 if $role eq $to;
            return $self->$next( $role );
        } );
        $DONE{$to}++;
        return;
    }

    sub CREATE_CLASS {
        my $base      = shift;
        my $new_class = "$base\::__WITH__::" . __PACKAGE__;
        {
            no strict 'refs';
            @{"$new_class\::ISA"} = $base;
        }
        APPLY_TO( $new_class );
        return $new_class;
    }
}
CODE
}

sub _compile_callback {
    my $self = shift;

    my @required = @{ $self->required_methods };
    my %uniq; undef $uniq{$_} for @required;
    @required = sort keys %uniq;

    my $role_list = join q[, ], map B::perlstring( $_->name ), @{ $self->roles };
    my $shim = B::perlstring(
        $self->shim_name
        || eval { $self->project->config->data->{shim} }
        || 'Mite::Shim'
    );
    my $croak = $self->_function_for_croak;
    my $missing_methods = '()';
    if ( @required ) {
        require B;
        $missing_methods = sprintf 'grep( !$target->can($_), %s )',
            join q[, ], map B::perlstring( $_ ), @required;
    }

    return sprintf <<'CODE', $missing_methods, $croak, $role_list, $croak, $shim;
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
    return if $type ne 'Mite::Class';

    my @missing_methods;
    @missing_methods = %s
        and %s( "$me requires $target to implement methods: " . join q[, ], @missing_methods );

    my @roles = ( %s );
    my %%nextargs = %%{ $args || {} };
    ( $nextargs{-indirect} ||= 0 )++;
    %s( "PANIC!" ) if $nextargs{-indirect} > 100;
    for my $role ( @roles ) {
        $role->__FINALIZE_APPLICATION__( $target, { %%nextargs } );
    }

    my $shim = %s;
    for my $modifier_rule ( @METHOD_MODIFIERS ) {
        my ( $modification, $names, $coderef ) = @$modifier_rule;
        my $handler = "HANDLE_$modification";
        $shim->$handler( $target, "class", $names, $coderef );
    }

    return;
}
CODE
}

sub _needs_accessors {
    my $self = shift;
    $self->arg->{'-runtime'} ? true : false;
}

sub _mop_metaclass {
    return 'Moose::Meta::Role';
}

sub _mop_attribute_metaclass {
   return 'Moose::Meta::Role::Attribute';
}

sub _compile_mop_modifiers {
    my $self = shift;

    return sprintf <<'CODE', $self->name;
    for ( @%s::METHOD_MODIFIERS ) {
        my ( $type, $names, $code ) = @$_;
        $PACKAGE->${\"add_$type\_method_modifier"}( $_, $code ) for @$names;
    }
CODE
}

sub _compile_mop_tc {
    return sprintf '    Moose::Util::TypeConstraints::find_or_create_does_type_constraint( %s );',
        B::perlstring( shift->name );
}

1;
