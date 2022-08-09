use 5.010001;
use strict;
use warnings;

package Mite::Class;
use Mite::Miteception -all;
extends qw(
    Mite::Package
);
with qw(
    Mite::Trait::HasSuperclasses
    Mite::Trait::HasConstructor
    Mite::Trait::HasDestructor
    Mite::Trait::HasAttributes
    Mite::Trait::HasRoles
    Mite::Trait::HasMethods
    Mite::Trait::HasMOP
);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.009003';

use Path::Tiny;
use mro;
use B ();

sub class {
    my ( $self, $name ) = ( shift, @_ );

    return $self->project->class($name);
}

sub chained_attributes {
    my ( $self, @classes ) = ( shift, @_ );

    my %attributes;
    for my $class (reverse @classes) {
        for my $attribute (values %{$class->attributes}) {
            $attributes{$attribute->name} = $attribute;
        }
    }

    return \%attributes;
}

around all_attributes => sub {
    my ( $next, $self ) = ( shift, shift );

    return $self->$next
        if not @{ $self->superclasses || [] };

    return $self->chained_attributes( $self->linear_parents );
};

sub parents_attributes {
    my $self = shift;

    my @parents = $self->linear_parents;
    shift @parents;  # remove ourselves from the inheritance list
    return $self->chained_attributes(@parents);
}

sub extend_method_signature {
    my ($self, $name, %args) = ( shift, @_ );

    my @parents = $self->linear_parents;
    shift @parents;  # remove ourselves from the inheritance list

    my $found_signature;
    for my $parent ( @parents ) {
        if ( $parent->method_signatures->{$name} ) {
            $found_signature = $parent->method_signatures->{$name};
            last;
        }
    }

    if ( $found_signature ) {
        $self->method_signatures->{$name} = %args 
            ? $found_signature->clone( %args, class => $self )
            : $found_signature;
    }
    else {
        croak "Could not find signature for $name in any parent class";
    }

    return;
}

around extend_attribute => sub {
    my ( $next, $self, %attr_args ) = ( shift, shift, @_ );

    my $name = delete $attr_args{name};

    if ( $self->attributes->{$name} ) {
        return $self->$next( name => $name, %attr_args );
    }

    my $parent_attr = $self->parents_attributes->{$name};
    croak <<'ERROR', $name, $self->name unless $parent_attr;
Could not find an attribute by the name of '%s' to inherit from in %s
ERROR

    if ( ref $attr_args{default} ) {
        $attr_args{_class_for_default} = $self;
    }

    $self->add_attribute($parent_attr->clone(%attr_args));

    return;
};

sub _needs_accessors {
    return true;
}

sub _mop_metaclass {
    return 'Moose::Meta::Class';
}

sub _mop_attribute_metaclass {
   return 'Moose::Meta::Attribute';
}

sub _compile_mop_postamble {
    my ( $next, $self ) = ( shift, shift );

    my $code = $self->$next( @_ );

    my @superclasses = @{ $self->superclasses || [] }
        or return $code;
    $code .= sprintf "Moose::Util::find_meta( %s )->superclasses( %s );\n",
        B::perlstring( $self->name ),
        join q{, }, map B::perlstring( $_ ), @superclasses;

    return $code;
}

1;

__END__

=pod

=head1 NAME

Mite::Class - a class within a project

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
