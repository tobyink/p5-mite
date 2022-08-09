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
our $VERSION   = '0.009003';

use Path::Tiny;
use B ();

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

around compilation_stages => sub {
    my ( $next, $self ) = ( shift, shift );
    my @stages = $self->$next( @_ );
    push @stages, '_compile_callback';
    return @stages;
};

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
        $shim->$modification( $target, $names, $coderef );
    }

    return;
}
CODE
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

__END__

=pod

=head1 NAME

Mite::Role - a role within a project

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
