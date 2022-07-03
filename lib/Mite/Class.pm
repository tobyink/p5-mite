use 5.010001;
use strict;
use warnings;

package Mite::Class;
use Mite::Miteception;
extends qw(Mite::Role);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.003001';

use Path::Tiny;
use mro;
use B ();

# Super classes as class names
has extends =>
  is            => 'bare',
  accessor      => 'superclasses',
  isa           => ArrayRef[Str],
  default       => sub { [] },
  trigger       => sub {
      my $self = shift;

      return if !$self->name; # called from constructor

      # Set up our @ISA so we can use mro to calculate the class hierarchy
      $self->_set_isa;

      # Allow $self->parents to recalculate itself
      $self->_clear_parents;
  };

# Super classes as Mite::Classes populated from $self->superclasses
has parents =>
  is            => ro,
  isa           => ArrayRef[InstanceOf['Mite::Class']],
  # Build on demand to allow the project to load all the classes first
  lazy          => true,
  builder       => '_build_parents',
  clearer       => '_clear_parents';

##-

sub BUILD {
    my $self = shift;
    $self->_trigger_extends( $self->superclasses )
        if $self->can('_trigger_extends');
}

sub class {
    my ( $self, $name ) = ( shift, @_ );

    return $self->project->class($name);
}

sub _set_isa {
    my $self = shift;

    my $name = $self->name;

    mro::set_mro($name, "c3");
    no strict 'refs';
    @{$name.'::ISA'} = @{$self->superclasses};

    return;
}

sub get_isa {
    my $self = shift;

    my $name = $self->name;

    no strict 'refs';
    return @{$name.'::ISA'};
}

sub linear_isa {
    my $self = shift;

    return @{mro::get_linear_isa($self->name)};
}

sub linear_parents {
    my $self = shift;

    my $project = $self->project;

    return grep defined, map { $project->class($_) } $self->linear_isa;
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

sub all_attributes {
    my $self = shift;

    return $self->attributes unless @{ $self->superclasses || [] };
    return $self->chained_attributes($self->linear_parents);
}

sub parents_attributes {
    my $self = shift;

    my @parents = $self->linear_parents;
    shift @parents;  # remove ourselves from the inheritance list
    return $self->chained_attributes(@parents);
}

sub _build_parents {
    my $self = shift;

    my $extends = $self->superclasses;
    return [] if !@$extends;

    # Load each parent and store its Mite::Class
    my @parents;
    for my $parent_name (@$extends) {
        push @parents, $self->_get_parent($parent_name);
    }

    return \@parents;
}

sub _get_parent {
    my ( $self, $parent_name ) = ( shift, @_ );

    my $project = $self->project;

    # See if it's already loaded
    my $parent = $project->class($parent_name);
    return $parent if $parent;

    # If not, try to load it
    eval "require $parent;";
    $parent = $project->class($parent_name);
    return $parent if $parent;

    croak <<"ERROR";
$parent loaded but is not a Mite class.
Extending non-Mite classes not yet supported.
Sorry.
ERROR
}

sub extend_attribute {
    my ($self, %attr_args) = ( shift, @_ );

    my $name = delete $attr_args{name};

    if ( $self->attributes->{$name} ) {
        return $self->SUPER::extend_attribute( name => $name, %attr_args );
    }

    my $parent_attr = $self->parents_attributes->{$name};
    croak(sprintf <<'ERROR', $name, $self->name) unless $parent_attr;
Could not find an attribute by the name of '%s' to inherit from in %s
ERROR

    if ( ref $attr_args{default} ) {
        $attr_args{_class_for_default} = $self;
    }

    $self->add_attribute($parent_attr->clone(%attr_args));

    return;
}

sub methods_to_export {
    return {};
}

sub compilation_stages {
    return qw(
        _compile_package
        _compile_uses_mite
        _compile_pragmas
        _compile_extends
        _compile_with
        _compile_new
        _compile_destroy
        _compile_meta_method
        _compile_does
        _compile_attribute_accessors
        _compile_composed_methods
    );
}

sub _compile_extends {
    my $self = shift;

    my $extends = $self->superclasses;
    return '' unless @$extends;

    my $source = $self->source;

    my $require_list = join "\n\t",
                            map  { "require $_;" }
                            # Don't require a class from the same source
                            grep { !$source || !$source->has_class($_) }
                            @$extends;

    my $isa_list     = join ", ", map B::perlstring($_), @$extends;

    return <<"END";
BEGIN {
    $require_list

    use mro 'c3';
    our \@ISA;
    push \@ISA, $isa_list;
}
END
}

sub _compile_new {
    my $self = shift;
    my @vars = ('$class', '$self', '$args', '$meta');

    return sprintf <<'CODE', $self->_compile_meta(@vars), $self->_compile_bless(@vars), $self->_compile_buildargs(@vars), $self->_compile_init_attributes(@vars), $self->_compile_strict_constructor(@vars), $self->_compile_buildall(@vars, '$no_build');
sub new {
    my $class = ref($_[0]) ? ref(shift) : shift;
    my $meta  = %s;
    my $self  = %s;
    my $args  = %s;
    my $no_build = delete $args->{__no_BUILD__};

    # Initialize attributes
    %s

    # Enforce strict constructor
    %s

    # Call BUILD methods
    %s

    return $self;
}
CODE
}

sub _compile_bless {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;

    return "bless {}, $classvar";
}

sub _compile_strict_constructor {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;

    my @allowed =
        grep { defined $_ }
        map { ( $_->init_arg, $_->_all_aliases ) }
        values %{ $self->all_attributes };
    my $check = do {
        local $Type::Tiny::AvoidCallbacks = 1;
        my $enum = Enum->of( @allowed );
        $enum->can( '_regexp' )  # not part of official API
            ? sprintf( '/\\A%s\\z/', $enum->_regexp )
            : $enum->inline_check( '$_' );
    };

    return sprintf 'my @unknown = grep not( %s ), keys %%{%s}; @unknown and require Carp and Carp::croak("Unexpected keys in constructor: " . join(q[, ], sort @unknown));',
        $check, $argvar;
}

sub _compile_buildargs {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;
    return sprintf '%s->{HAS_BUILDARGS} ? %s->BUILDARGS( @_ ) : { ( @_ == 1 ) ? %%{$_[0]} : @_ }',
        $metavar, $classvar;
}

sub _compile_buildall {
    my ( $self, $classvar, $selfvar, $argvar, $metavar, $nobuildvar ) = @_;
    return sprintf 'unless ( %s ) { $_->(%s, %s) for @{ %s->{BUILD} || [] } };',
        $nobuildvar, $selfvar, $argvar, $metavar;
}

sub _compile_destroy {
    my $self = shift;
    sprintf <<'CODE', $self->_compile_meta( '$class', '$self' );
sub DESTROY {
    my $self  = shift;
    my $class = ref( $self ) || $self;
    my $meta  = %s;
    my $in_global_destruction = defined ${^GLOBAL_PHASE}
        ? ${^GLOBAL_PHASE} eq 'DESTRUCT'
        : Devel::GlobalDestruction::in_global_destruction();
    for my $demolisher ( @{ $meta->{DEMOLISH} || [] } ) {
        my $e = do {
            local ( $?, $@ );
            eval { $demolisher->( $self, $in_global_destruction ) };
            $@;
        };
        no warnings 'misc'; # avoid (in cleanup) warnings
        die $e if $e;       # rethrow
    }
    return;
}
CODE
}

sub _compile_meta {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;
    return sprintf '( $Mite::META{%s} ||= %s->__META__ )',
        $classvar, $classvar;
}

sub _compile_init_attributes {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;

    my @code;
    my $depth = 1;
    my %depth = map { $_ => $depth++; } $self->linear_isa;
    my @attributes = do {
        no warnings;
        sort {
            eval { $depth{$b->class->name} <=> $depth{$a->class->name} }
            or $a->_order <=> $b->_order;
        }
        values %{ $self->all_attributes };
    };
    for my $attr ( @attributes ) {
        my $code = $attr->compile_init( $selfvar, $argvar );
        push @code, $code if $code;
    }

    return join "\n    ", @code;
}

sub _compile_attribute_accessors {
    my $self = shift;

    my $attributes = $self->attributes;
    keys %$attributes or return '';

    my $code = 'my $__XS = !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };' . "\n\n";
    for my $name ( sort keys %$attributes ) {
        $code .= $attributes->{$name}->compile( xs_condition => '$__XS' );
    }

    return $code;
}

1;

__END__

=pod

=head1 NAME

Mite::Class - Representing a class within a project.

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
