use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasAttributes;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010004';

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

before inject_mite_functions => sub {
    my ( $self, $file, $arg ) = ( shift, @_ );

    my $requested = sub { $arg->{$_[0]} ? 1 : $arg->{'!'.$_[0]} ? 0 : $arg->{'-all'} ? 1 : $_[1]; };
    my $shim      = $self->shim_name;
    my $package   = $self->name;
    my $kind      = $self->kind;

    my $ctxt      = sub {
        my $level = shift;
        my @info  = caller( $level );
        return {
            'toolkit' => 'Mite',
            'package' => $info[0],
            'file'    => $info[1],
            'line'    => $info[2],
            @_,
        };
    };

    no strict 'refs';

    my $has = sub {
        my $names = shift;
        if ( @_ % 2 ) {
            my $default = shift;
            unshift @_, ( 'CODE' eq ref( $default ) )
                ? ( is => lazy, builder => $default )
                : ( is => ro, default => $default );
        }
        my %spec = @_;
        $spec{definition_context} ||= $ctxt->( 1, file => "$file", type => $kind, context => 'has declaration' );

        for my $name ( ref($names) ? @$names : $names ) {
            if( my $is_extension = $name =~ s{^\+}{} ) {
                $self->extend_attribute(
                    class   => $self,
                    name    => $name,
                    %spec
                );
            }
            else {
                require Mite::Attribute;
                my $attribute = Mite::Attribute->new(
                    class   => $self,
                    name    => $name,
                    %spec
                );
                $self->add_attribute($attribute);
            }
            my $code;
            'CODE' eq ref( $code = $spec{builder} )
                and *{"$package\::_build_$name"} = $code;
            'CODE' eq ref( $code = $spec{trigger} )
                and *{"$package\::_trigger_$name"} = $code;
            'CODE' eq ref( $code = $spec{clone} )
                and *{"$package\::_clone_$name"} = $code;
        }

        return;
    };

    if ( $requested->( 'has', true ) ) {

        *{ $package .'::has' } = $has;

        $self->imported_keywords->{has} = 'sub { $SHIM->HANDLE_has( $CALLER, has => @_ ) }';
    }

    if ( $requested->( 'param', false ) ) {

        *{"$package\::param"} = sub {
            my ( $names, %spec ) = @_;
            $spec{is} = ro unless exists $spec{is};
            $spec{required} = true unless exists $spec{required};
            $spec{definition_context} ||= $ctxt->( 1, file => "$file", type => $kind, context => 'param declaration' );
            $has->( $names, %spec );
        };

        $self->imported_keywords->{param} = 'sub { $SHIM->HANDLE_has( $CALLER, param => @_ ) }';
    }

    if ( $requested->( 'field', false ) ) {

        *{"$package\::field"} = sub {
            my ( $names, %spec ) = @_;
            $spec{is} ||= ( $spec{builder} || exists $spec{default} ) ? lazy : rwp;
            $spec{init_arg} = undef unless exists $spec{init_arg};
            if ( defined $spec{init_arg} and $spec{init_arg} !~ /^_/ ) {
                croak "A defined 'field.init_arg' must begin with an underscore: %s ", $spec{init_arg};
            }
            $spec{definition_context} ||= $ctxt->( 1, file => "$file", type => $kind, context => 'field declaration' );
            $has->( $names, %spec );
        };

        $self->imported_keywords->{field} = 'sub { $SHIM->HANDLE_has( $CALLER, field => @_ ) }';
    }
};

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
