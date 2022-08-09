use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasAttributes;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010000';

requires qw( _function_for_croak );

has attributes =>
  is            => ro,
  isa           => HashRef[MiteAttribute],
  default       => sub { {} };

sub all_attributes {
    shift->attributes;
}

signature_for add_attributes => (
    pos => [ slurpy ArrayRef[MiteAttribute] ],
);

sub add_attributes {
    my ( $self, $attributes ) = @_;

    for my $attribute (@$attributes) {
        croak '%s already has an attribute called %s', $self->name, $attribute->_q_name
            if $self->attributes->{ $attribute->name };
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
    croak <<'ERROR', $name, $self->name unless $attr;
Could not find an attribute by the name of '%s' to extend in %s
ERROR

    if ( ref $attr_args{default} ) {
        $attr_args{_class_for_default} = $self;
    }

    $self->attributes->{$name} = $attr->clone(%attr_args);

    return;
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
        my $guard = $attr->locally_set_compiling_class( $self );
        my @lines = grep !!$_, $attr->compile_init( $selfvar, $argvar );
        if ( @lines ) {
            push @code, sprintf "# Attribute %s%s",
               $attr->name, $attr->type ? sprintf( ' (type: %s)', $attr->type->display_name ) : '';
            push @code, sprintf '# %s',
               $attr->definition_context_to_pretty_string;
            push @code, @lines;
            push @code, '';
        }
    }

    return join "\n", map { /\S/ ? "    $_" : '' } @code;
}

sub _needs_accessors {
    return false;
}

around _compile_pragmas => sub {
    my ( $next, $self ) = ( shift, shift );

    my $code = $self->$next( @_ );
    return $code unless
        grep   { defined($_) and $_ eq true }
        map    { $_->cloner_method }
        values %{ $self->all_attributes };

    return "use Storable ();\n" . $code;
};

around compilation_stages => sub {
    my ( $next, $self ) = ( shift, shift );
    my @stages = $self->$next( @_ );
    push @stages, qw(
        _compile_attribute_accessors
    ) if $self->_needs_accessors;
    return @stages;
}; 

sub _compile_attribute_accessors {
    my $self = shift;

    my $attributes = $self->attributes;
    keys %$attributes or return '';

    my $code = 'my $__XS = !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") };' . "\n\n";
    for my $name ( sort keys %$attributes ) {
        my $guard = $attributes->{$name}->locally_set_compiling_class( $self );
        $code .= $attributes->{$name}->compile( xs_condition => '$__XS' );
    }

    return $code;
}

around _compile_mop_attributes => sub {
    my ( $next, $self ) = ( shift, shift );

    my $code = $self->$next( @_ );

    my @attrs =
        sort { $a->_order <=> $b->_order }
        values %{ $self->attributes };
    if ( @attrs ) {
        $code .= "    my \%ATTR;\n\n";
        for my $attr ( @attrs ) {
            my $guard = $attr->locally_set_compiling_class( $self );
            my $attr_code = $attr->_compile_mop;
            $attr_code =~ s/^/    /gm;
            $code .= $attr_code . "\n";
        }
    }

    return $code;
};

1;
