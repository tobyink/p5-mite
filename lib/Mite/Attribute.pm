use 5.010001;
use strict;
use warnings;

package Mite::Attribute;
use Mite::Miteception qw( -all !lazy );

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.006006';

has _order =>
  is            => rw,
  init_arg      => undef,
  builder       => sub { state $order = 0; $order++ };

has class =>
  is            => rw,
  isa           => Object,
  weak_ref      => true;

has compiling_class =>
  init_arg      => undef,
  is            => rw,
  isa           => Object,
  clearer       => true,
  predicate     => true;

has _class_for_default =>
  is            => rw,
  isa           => Object,
  weak_ref      => true,
  lazy          => true,
  builder       => sub { shift->class };

has name =>
  is            => rw,
  isa           => Str->where('length($_) > 0'),
  required      => true;

has init_arg =>
  is            => rw,
  isa           => Str|Undef,
  default       => sub { shift->name },
  lazy          => true;

has required =>
  is            => rw,
  isa           => Bool,
  default       => false;

has weak_ref =>
  is            => rw,
  isa           => Bool,
  default       => false;

has is =>
  is            => rw,
  isa           => Enum[ ro, rw, rwp, 'lazy', bare ],
  default       => bare;

has [ 'reader', 'writer', 'accessor', 'clearer', 'predicate', 'lvalue', 'local_writer' ] =>
  is            => rw,
  isa           => Str->where('length($_) > 0') | Undef,
  builder       => true,
  lazy          => true;

has isa =>
  is            => bare,
  isa           => Str|Object,
  reader        => '_%s'; # collision with UNIVERSAL::isa

has does =>
  is            => bare,
  isa           => Str|Object,
  reader        => '_%s'; # collision with Mite's does method

has type =>
  is            => 'lazy',
  isa           => Object|Undef,
  builder       => true;

has coerce =>
  is            => rw,
  isa           => Bool,
  default       => false;

has default =>
  is            => rw,
  isa           => Undef|Str|CodeRef|ScalarRef,
  predicate     => true;

has lazy =>
  is            => rw,
  isa           => Bool,
  default       => false;

has coderef_default_variable =>
  is            => rw,
  isa           => Str,
  lazy          => true,     # else $self->name might not be set
  default       => sub {
      # This must be coordinated with Mite.pm
      return sprintf '$%s::__%s_DEFAULT__', $_[0]->_class_for_default->name, $_[0]->name;
  };

has [ 'trigger', 'builder' ] =>
  is            => rw,
  isa           => Str->where('length($_) > 0') | CodeRef | Undef,
  predicate     => true;

has documentation =>
  is            => rw,
  predicate     => true;

has handles =>
  is            => rw,
  isa           => HashRef->of( Str )->plus_coercions( ArrayRef, q{+{ map { $_ => $_ } @$_ }} ),
  predicate     => true,
  coerce        => true;

has alias =>
  is            => rw,
  isa           => ArrayRef->of(Str)->plus_coercions( Str, q{ [$_] }, Undef, q{ [] } ),
  coerce        => true,
  default       => sub { [] };

has alias_is_for =>
  is            => 'lazy',
  init_arg      => undef;

##-

use B ();
sub _q          { shift; join q[, ], map B::perlstring($_), @_ }
sub _q_name     { B::perlstring( shift->name ) }
sub _q_init_arg { my $self = shift; B::perlstring( $self->_expand_name( $self->init_arg ) ) }

for my $function ( qw/ carp croak confess / ) {
    no strict 'refs';
    *{"_function_for_$function"} = sub {
        my $self = shift;
        return $self->compiling_class->${\"_function_for_$function"}
            if $self->has_compiling_class;
        my $shim = eval { $self->class->shim_name };
        return "$shim\::$function" if $shim;
        $function eq 'carp' ? 'warn sprintf' : 'die sprintf';
    };
}

my @method_name_generator = (
    { # public
        reader        => sub { "get_$_" },
        writer        => sub { "set_$_" },
        accessor      => sub { $_ },
        lvalue        => sub { $_ },
        clearer       => sub { "clear_$_" },
        predicate     => sub { "has_$_" },
        builder       => sub { "_build_$_" },
        trigger       => sub { "_trigger_$_" },
        local_writer  => sub { "locally_set_$_" },
    },
    { # private
        reader        => sub { "_get_$_" },
        writer        => sub { "_set_$_" },
        accessor      => sub { $_ },
        lvalue        => sub { $_ },
        clearer       => sub { "_clear_$_" },
        predicate     => sub { "_has_$_" },
        builder       => sub { "_build_$_" },
        trigger       => sub { "_trigger_$_" },
        local_writer  => sub { "_locally_set_$_" },
    },
);

sub BUILD {
    my $self = shift;

    croak "Required attribute with no init_arg"
        if $self->required && !defined $self->init_arg;

    if ( $self->is eq 'lazy' ) {
        $self->lazy( true );
        $self->builder( true ) unless $self->has_builder;
        $self->is( ro );
    }

    for my $property ( 'builder', 'trigger' ) {
        if ( CodeRef->check( $self->$property ) ) {
            $self->$property( true );
        }
    }

    for my $property ( 'reader', 'writer', 'accessor', 'clearer', 'predicate', 'builder', 'trigger', 'lvalue', 'local_writer' ) {
        my $name = $self->$property;
        if ( defined $name and $name eq true ) {
            my $gen = $method_name_generator[$self->is_private]{$property};
            local $_ = $self->name;
            my $newname = $gen->( $_ );
            $self->$property( $newname );
        }
    }

    if ( defined $self->lvalue ) {
        if ( $self->lazy ) {
            require Mite::Shim;
            Mite::Shim::croak( 'Attributes with lazy defaults cannot have an lvalue accessor' );
        }
        elsif ( $self->trigger ) {
            require Mite::Shim;
            Mite::Shim::croak( 'Attributes with triggers cannot have an lvalue accessor' );
        }
        elsif ( $self->weak_ref ) {
            require Mite::Shim;
            Mite::Shim::croak( 'Attributes with weak_ref cannot have an lvalue accessor' );
        }
        elsif ( $self->type or $self->coerce ) {
            require Mite::Shim;
            Mite::Shim::croak( 'Attributes with type constraints or coercions cannot have an lvalue accessor' );
        }
    }
}

sub _expand_name {
    my ( $self, $name ) = @_;

    return undef unless defined $name;
    return $name unless $name =~ /\%/;

    my %tokens = (
        's' => $self->name,
        '%' => '%',
    );

    $name =~ s/%(.)/$tokens{$1}/eg;
    return $name;
}

sub clone {
    my ( $self, %args ) = ( shift, @_ );

    if ( exists $args{is} ) {
        croak "Cannot use the `is` shortcut when extending an attribute";
    }

    my %inherit = %$self;

    # type will need to be rebuilt
    delete $inherit{type} if $args{isa} || $args{type};

    # these should not be cloned at all
    delete $inherit{coderef_default_variable};
    delete $inherit{_order};

    return ref($self)->new( %inherit, %args );
}

sub is_private {
    0+!! ( shift->name =~ /^_/ );
}

sub _build_reader {
    my $self = shift;
    ( $self->is eq ro or $self->is eq rwp ) ? '%s' : undef;
}

sub _build_writer {
    my $self = shift;
    ( $self->is eq rwp ) ? '_set_%s' : undef;
}

sub _build_accessor {
    my $self = shift;
    ( $self->is eq rw ) ? '%s' : undef;
}

sub _build_predicate { undef; }

sub _build_clearer { undef; }

sub _build_lvalue { undef; }

sub _build_local_writer { undef; }

sub _build_alias_is_for {
    my $self = shift;
    return undef unless @{ $self->alias };
    my @seek_order = $self->is eq rw
        ? qw( accessor reader lvalue writer )
        : qw( reader accessor lvalue writer );
    for my $sought ( @seek_order ) {
        return $sought if $self->$sought;
    }
    return undef;
}

sub _all_aliases {
    my $self    = shift;
    my $aliases = $self->alias;
    return unless @$aliases;
    map $self->_expand_name($_), @$aliases;
}

sub _build_type {
    my $self = shift;

    my ( $fallback, $string );
    if ( my $isa = $self->_isa ) {
        $string   = $isa;
        $fallback = [ 'make_class_type' ];
    }
    elsif ( my $does = $self->_does ) {
        $string   = $does;
        $fallback = [ 'make_role_type' ];
    }
    else {
        return undef;
    }

    my $type;
    if ( ref $string ) {
        $type = $string;
    }
    else {
        require Type::Utils;
        $type = Type::Utils::dwim_type(
            $string,
            fallback => $fallback,
            for      => $self->class->name,
        );

        $type or croak 'Type %s cannot be found', $string;
    }

    $type->can_be_inlined
        or croak 'Type %s cannot be inlined', $type->display_name;

    if ( $self->coerce ) {
        $type->has_coercion
            or carp 'Type %s has no coercions', $type->display_name;
        $type->coercion->can_be_inlined
            or carp 'Coercion to type %s cannot be inlined', $type->display_name;
    }

    return $type;
}

sub has_coderef_default {
    my $self = shift;

    # We don't have a default
    return 0 unless $self->has_default;

    return CodeRef->check( $self->default );
}

sub has_inline_default {
    my $self = shift;

    # We don't have a default
    return 0 unless $self->has_default;

    return ScalarRef->check( $self->default );
}

sub has_simple_default {
    my $self = shift;

    return 0 unless $self->has_default;

    return !ref $self->default;
}

sub _compile_coercion {
    my ( $self, $expression ) = @_;
    if ( $self->coerce and my $type = $self->type ) {
        local $Type::Tiny::AvoidCallbacks = 1;
        return sprintf 'do { my $to_coerce = %s; %s }',
            $expression, $type->coercion->inline_coercion( '$to_coerce' );
    }
    return $expression;
}

sub _compile_checked_default {
    my ( $self, $selfvar ) = @_;

    my $default = $self->_compile_default( $selfvar );
    my $type = $self->type or return $default;

    local $Type::Tiny::AvoidCallbacks = 1;

    if ( $self->coerce ) {
        $default = $self->_compile_coercion( $default );
    }

    return sprintf 'do { my $default_value = %s; %s or %s( "Type check failed in default: %%s should be %%s", %s, %s ); $default_value }',
        $default, $type->inline_check('$default_value'), $self->_function_for_croak, $self->_q($self->name), $self->_q($type->display_name);
}

sub _compile_default {
    my ( $self, $selfvar ) = @_;

    if ( $self->has_coderef_default ) {
        my $var = $self->coderef_default_variable;
        return sprintf 'do { my $method = %s; %s->$method }',
          $var, $selfvar;
    }
    elsif ( $self->has_inline_default ) {
        return ${ $self->default };
    }
    elsif ( $self->has_simple_default ) {
        return defined( $self->default ) ? $self->_q( $self->default ) : 'undef';
    }
    elsif ( $self->has_builder ) {
        return sprintf '%s->%s', $selfvar, $self->_expand_name( $self->builder );
    }

    # should never get here
    return 'undef';
}

sub _compile_trigger {
    my ( $self, $selfvar, @args ) = @_;
    my $method_name = $self->_expand_name( $self->trigger );

    return sprintf '%s->%s( %s )',
        $selfvar, $method_name, join( q{, }, @args );
}

sub compile_init {
    my ( $self, $selfvar, $argvar ) = @_;

    my $init_arg = $self->_expand_name( $self->init_arg );

    my @code;
    if ( defined $init_arg ) {

        if ( my @alias = $self->_all_aliases ) {
            push @code, sprintf 'for my $alias ( %s ) { last if exists %s->{%s}; next if !exists %s->{$alias}; %s->{%s} = %s->{$alias} } ',
                $self->_q( @alias ), $argvar, $self->_q_init_arg, $argvar, $argvar, $self->_q_init_arg, $argvar;
        }

        my $code;
        my $valuevar = sprintf '%s->{%s}', $argvar, $self->_q_init_arg;
        my $postamble = '';

        if ( $self->has_default || $self->has_builder and not $self->lazy ) {
            $code .= sprintf 'do { my $value = exists( %s ) ? %s : %s; ',
                $valuevar, $valuevar, $self->_compile_default( $selfvar );
            $valuevar = '$value';
            $postamble = "}; $postamble";
        }
        elsif ( $self->required and not $self->lazy ) {
            push @code, sprintf '%s "Missing key in constructor: %s" unless exists %s; ',
                $self->_function_for_croak, $init_arg, $valuevar;
        }
        else {
            my $trigger_code = $self->trigger
                ? $self->_compile_trigger(
                    $selfvar,
                    sprintf( '%s->{%s}', $selfvar, $self->_q_name ),
                ) . '; '
                : '';

            $code .= sprintf 'if ( exists %s->{%s} ) { ',
                $argvar, $self->_q_init_arg;
            $postamble = "$trigger_code} $postamble";
        }

        if ( my $type = $self->type ) {
            local $Type::Tiny::AvoidCallbacks = 1;
            
            if ( $self->coerce ) {
                $code .= sprintf 'do { my $coerced_value = %s; ', $self->_compile_coercion( $valuevar );
                $valuevar = '$coerced_value';
                $postamble = "}; $postamble";
            }

            $code .= sprintf '%s or %s "Type check failed in constructor: %%s should be %%s", %s, %s; ',
                $type->inline_check( $valuevar ),
                $self->_function_for_croak,
                $self->_q_init_arg,
                $self->_q( $type->display_name );

            $code .= sprintf '%s->{%s} = %s; ',
                $selfvar, $self->_q_name, $valuevar;
        }
        else {
            $code .= sprintf '%s->{%s} = %s; ',
                $selfvar, $self->_q_name, $valuevar;
        }
        
        $code .= $postamble;
        push @code, $code;
    }
    elsif ( $self->has_default || $self->has_builder and not $self->lazy ) {
        push @code, sprintf '%s->{%s} = %s; ',
            $selfvar, $self->_q_name, $self->_compile_checked_default( $selfvar );
    }

    if ( $self->weak_ref ) {
        push @code, sprintf 'require Scalar::Util && Scalar::Util::weaken(%s->{%s}) if exists %s->{%s};',
            $selfvar, $self->_q_name, $selfvar, $self->_q_name;
    }

    for ( @code ) {
        $_ = "$_;" unless /;\s*$/;
    }

    return @code;
}

my %code_template;
%code_template = (
    reader => sub {
        my $self = shift;
        my %arg = @_;
        my $code = sprintf '$_[0]{%s}', $self->_q_name;
        if ( $self->lazy ) {
            $code = sprintf '( exists($_[0]{%s}) ? $_[0]{%s} : ( $_[0]{%s} = %s ) )',
                $self->_q_name, $self->_q_name, $self->_q_name, $self->_compile_checked_default( '$_[0]' );
        }
        unless ( $arg{no_croak} ) {
            $code = sprintf '@_ > 1 ? %s( "%s is a read-only attribute of @{[ref $_[0]]}" ) : %s',
                $self->_function_for_croak, $self->name, $code;
        }
        return $code;
    },
    asserter => sub {
        my $self = shift;
        my %arg = @_;
        my $reader  = $code_template{reader}->( $self, no_croak => true );
        my $blessed = 'require Scalar::Util && Scalar::Util::blessed';
        if ( $self->class and $self->class->imported_functions->{blessed} ) {
           $blessed = 'blessed';
        }
        return sprintf 'my $object = do { %s }; %s($object) or %s( "%s is not a blessed object" ); $object',
            $reader, $blessed, $self->_function_for_croak, $self->name;
    },
    writer => sub {
        my $self = shift;
        my %arg = @_;
        my $code = '';
        if ( $self->trigger ) {
            $code .= sprintf 'my @oldvalue; @oldvalue = $_[0]{%s} if exists $_[0]{%s}; ',
                $self->_q_name, $self->_q_name;
        }
        if ( my $type = $self->type ) {
            local $Type::Tiny::AvoidCallbacks = 1;
            my $valuevar = '$_[1]';
            if ( $self->coerce ) {
                $code .= sprintf 'my $value = %s; ', $self->_compile_coercion($valuevar);
                $valuevar = '$value';
            }
            $code .= sprintf '%s or %s( "Type check failed in %%s: value should be %%s", %s, %s ); $_[0]{%s} = %s;',
                $type->inline_check($valuevar), $self->_function_for_croak, $self->_q( $arg{label} // 'writer' ), $self->_q( $type->display_name ), $self->_q_name, $valuevar;
        }
        else {
            $code .= sprintf '$_[0]{%s} = $_[1];', $self->_q_name;
        }
        if ( $self->trigger ) {
            $code .= ' ' . $self->_compile_trigger(
                '$_[0]',
                sprintf( '$_[0]{%s}', $self->_q_name ),
                '@oldvalue',
            ) . ';';
        }
        if ( $self->weak_ref ) {
            $code .= sprintf ' require Scalar::Util && Scalar::Util::weaken($_[0]{%s});',
                $self->_q_name;
        }
        $code .= ' $_[0];';
        return $code;
    },
    accessor => sub {
        my $self = shift;
        my %arg = @_;
        my @parts = (
            $code_template{writer}->( $self, label => 'accessor' ),
            $code_template{reader}->( $self, no_croak => true ),
        );
        for my $i ( 0 .. 1 ) {
            $parts[$i] = $parts[$i] =~ /\;/
                ? "do { $parts[$i] }"
                : "( $parts[$i] )"
        }
        sprintf '@_ > 1 ? %s : %s', @parts;
    },
    clearer => sub {
        my $self = shift;
        my %arg = @_;
        sprintf 'delete $_[0]{%s}; $_[0];', $self->_q_name;
    },
    predicate => sub {
        my $self = shift;
        sprintf 'exists $_[0]{%s}', $self->_q_name;
    },
    lvalue => sub {
        my $self = shift;
        sprintf '$_[0]{%s}', $self->_q_name;
    },
    local_writer => sub {
        my $self = shift;

        my $CROAK = $self->_function_for_croak;
        my $GET = $self->reader ? $self->_q( $self->_expand_name( $self->reader ) )
            : $self->accessor ? $self->_q( $self->_expand_name( $self->accessor ) )
            : sprintf( 'sub { %s }', $code_template{reader}->( $self, no_croak => true ) );
        my $SET = $self->writer ? $self->_q( $self->_expand_name( $self->writer ) )
            : $self->accessor ? $self->_q( $self->_expand_name( $self->accessor ) )
            : sprintf( 'sub { %s }', $code_template{writer}->( $self, label => 'local writer' ) );
        my $HAS = $self->predicate ? $self->_q( $self->_expand_name( $self->predicate ) )
            : sprintf( 'sub { %s }', $code_template{predicate}->( $self ) );
        my $CLEAR = $self->clearer ? $self->_q( $self->_expand_name( $self->clearer ) )
            : sprintf( 'sub { %s }', $code_template{clearer}->( $self ) );
        my $GUARD_NS = $self->compiling_class->imported_functions->{guard} ? ''
            : ( eval { $self->compiling_class->shim_name } || eval { $self->class->shim_name } || die() );
        $GUARD_NS .= '::' if $GUARD_NS;

        return sprintf <<'CODE', $CROAK, $GET, $SET, $HAS, $CLEAR, $GUARD_NS;

    defined wantarray or %s( "This method cannot be called invoid context" );
    my $get = %s;
    my $set = %s;
    my $has = %s;
    my $clear = %s;
    my $old = undef;
    my ( $self, $new ) = @_;
    my $restorer = $self->$has
        ? do { $old = $self->$get; sub { $self->$set( $old ) } }
        : sub { $self->$clear };
    @_ == 2 ? $self->$set( $new ) : $self->$clear;
    &%sguard( $restorer, $old );
CODE
    },
);

my %code_attr = (
    lvalue => ' :lvalue',
);

sub compile {
    my $self = shift;
    my %args = @_;

    my $xs_condition = $args{xs_condition}
        || '!$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor; Class::XSAccessor->VERSION("1.19") }';
    my $slot_name = $self->name;

    my %xs_option_name = (
        reader    => 'getters',
        writer    => 'setters',
        accessor  => 'accessors',
        predicate => 'exists_predicates',
        lvalue    => 'lvalue_accessors',
    );

    my %want_xs;
    my %want_pp;
    my %method_name;

    for my $property ( keys %code_template ) {
        my $method_name = $self->can($property) ? $self->$property : undef;
        next unless defined $method_name;

        $method_name{$property} = $self->_expand_name( $method_name );
        if ( $xs_option_name{$property} ) {
            $want_xs{$property} = 1;
        }
        $want_pp{$property} = 1;
    }

    if ( $self->has_handles ) {
        $method_name{asserter} = sprintf '_assert_blessed_%s', $self->name;
        $want_pp{asserter} = 1;
    }

    # Class::XSAccessor can't do type checks, triggers, or weaken
    if ( $self->type or $self->weak_ref or $self->trigger ) {
        delete $want_xs{writer};
        delete $want_xs{accessor};
    }

    # Class::XSAccessor can't do lazy builders checks
    if ( $self->lazy ) {
        delete $want_xs{reader};
        delete $want_xs{accessor};
    }

    my $code = "# Accessors for $slot_name\n";
    if ( keys %want_xs ) {
        $code .= "if ( $xs_condition ) {\n";
        $code .= "    Class::XSAccessor->import(\n";
        $code .= "        chained => 1,\n";
        for my $property ( sort keys %want_xs ) {
            $code .= sprintf "        %s => { %s => %s },\n",
                $self->_q( $xs_option_name{$property} ), $self->_q( $method_name{$property} ), $self->_q_name;
        }
        $code .= "    );\n";
        $code .= "}\n";
        $code .= "else {\n";
        for my $property ( sort keys %want_xs ) {
            $code .= sprintf '    *%s = sub%s { %s };' . "\n",
                $method_name{$property}, $code_attr{$property} || '', $code_template{$property}->($self);
            delete $want_pp{$property};
        }
        $code .= "}\n";
    }

    for my $property ( sort keys %want_pp ) {
        $code .= sprintf 'sub %s%s { %s }' . "\n",
            $method_name{$property}, $code_attr{$property} || '', $code_template{$property}->($self);
    }

    $code .= "\n";

    if ( my $alias_is_for = $self->alias_is_for ) {
        $code .= sprintf "# Aliases for for %s\n", $self->name;
        my $alias_target = $self->_expand_name( $self->$alias_is_for );
        for my $alias ( $self->_all_aliases ) {
            $code .= sprintf 'sub %s { shift->%s( @_ ) }' . "\n",
                $alias, $alias_target;
        }
        $code .= "\n";
    }

    if ( $self->has_handles ) {
        $code .= sprintf "# Delegated methods for %s\n", $self->name;
        my $assertion = $method_name{asserter};
        my %delegated = %{ $self->handles };
        for my $key ( sort keys %delegated ) {
            $code .= sprintf 'sub %s { shift->%s->%s( @_ ) }' . "\n",
                $self->_expand_name( $key ), $assertion, $delegated{$key};
        }
        $code .= "\n";
    }

    return $code;
}

1;

__END__

=pod

=head1 NAME

Mite::Attribute - an attribute in a class or role

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
