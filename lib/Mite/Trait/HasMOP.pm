use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasMOP;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.012000';

requires qw(
    _mop_metaclass
    _mop_attribute_metaclass
);

sub _compile_mop {
    my $self = shift;

    return sprintf <<'CODE', $self->_mop_metaclass, B::perlstring( $self->name ), B::perlstring( $self->name ), $self->_compile_mop_attributes, $self->_compile_mop_required_methods, $self->_compile_mop_modifiers, $self->_compile_mop_methods, $self->_compile_mop_tc;
{
    my $PACKAGE = %s->initialize( %s, package => %s );

%s
%s
%s
%s
%s
}
CODE
}

sub _compile_mop_attributes {
    return '';
}

sub _compile_mop_required_methods {
    return '';
}

sub _compile_mop_modifiers {
    return '';
}

sub _compile_mop_methods {
    my $self = shift;
    return sprintf <<'CODE', $self->name, B::perlstring( $self->name );
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&%s::meta,
            package_name => %s,
        ),
    );
CODE
}

sub _compile_mop_tc {
    return sprintf '    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( %s );',
        B::perlstring( shift->name );
}

sub _compile_mop_postamble {
    return '';
}

1;
