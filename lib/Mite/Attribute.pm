use 5.010001;
use strict;
use warnings;

package Mite::Attribute;
use Mite::Miteception qw( -all !lazy );

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.008001';

use B ();
use List::Util ();

my $order = 0;
has _order =>
  is            => rw,
  init_arg      => undef,
  builder       => sub { $order++ };

has definition_context => 
  is            => rw,
  isa           => HashRef,
  default       => \ '{}';

has class =>
  is            => rw,
  isa           => MiteRole,
  weak_ref      => true;

has compiling_class =>
  init_arg      => undef,
  is            => rw,
  isa           => MiteRole,
  local_writer  => true;

has _class_for_default =>
  is            => rw,
  isa           => MiteRole,
  weak_ref      => true,
  lazy          => true,
  builder       => sub { $_[0]->class || $_[0]->compiling_class };

has name =>
  is            => rw,
  isa           => NonEmptyStr,
  required      => true;

has init_arg =>
  is            => rw,
  isa           => NonEmptyStr|Undef,
  default       => sub { shift->name },
  lazy          => true;

has required =>
  is            => rw,
  isa           => Bool,
  coerce        => true,
  default       => false,
  default_is_trusted => true;

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
  isa           => MethodNameTemplate|One|Undef,
  builder       => true,
  lazy          => true;

has isa =>
  is            => bare,
  isa           => Str|Ref,
  reader        => '_%s'; # collision with UNIVERSAL::isa

has does =>
  is            => bare,
  isa           => Str|Ref,
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
  isa           => Undef | Str | CodeRef | ScalarRef | Dict[] | Tuple[],
  documentation => 'We support more possibilities than Moose!',
  predicate     => true;

has [ 'default_is_trusted', 'default_does_trigger' ] =>
  is            => rw,
  isa           => Bool,
  coerce        => true,
  default       => false,
  default_is_trusted => true;

has lazy =>
  is            => rw,
  isa           => Bool,
  default       => false;

has coderef_default_variable =>
  is            => rw,
  isa           => NonEmptyStr,
  lazy          => true,     # else $self->name might not be set
  default       => sub {
      # This must be coordinated with Mite.pm
      return sprintf '$%s::__%s_DEFAULT__', $_[0]->_class_for_default->name, $_[0]->name;
  };

has [ 'trigger', 'builder' ] =>
  is            => rw,
  isa           => MethodNameTemplate|One|CodeRef,
  predicate     => true;

has clone =>
  is            => bare,
  isa           => MethodNameTemplate|One|CodeRef|Undef,
  reader        => 'cloner_method';

has [ 'clone_on_read', 'clone_on_write' ] =>
  is            => 'lazy',
  isa           => Bool,
  coerce        => true,
  builder       => sub { !! shift->cloner_method };

has documentation =>
  is            => rw,
  predicate     => true;

has handles =>
  is            => rw,
  isa           => HandlesHash,
  predicate     => true,
  coerce        => true;

has alias =>
  is            => rw,
  isa           => AliasList,
  coerce        => true,
  default       => sub { [] };

has alias_is_for =>
  is            => 'lazy',
  init_arg      => undef;

sub _q          { shift; join q[, ], map B::perlstring($_), @_ }
sub _q_name     { B::perlstring( shift->name ) }
sub _q_init_arg { my $self = shift; B::perlstring( $self->_expand_name( $self->init_arg ) ) }

for my $function ( qw/ carp croak confess / ) {
    no strict 'refs';
    *{"_function_for_$function"} = sub {
        my $self = shift;
        return $self->compiling_class->${\"_function_for_$function"}
            if defined $self->compiling_class;
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
        clone         => sub { "_clone_$_" },
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
        clone         => sub { "_clone_$_" },
    },
);

sub BUILD {
    my $self = shift;

    croak "Required attribute with no init_arg"
        if $self->required && !defined $self->init_arg;

    if ( $self->is eq 'lazy' ) {
        $self->lazy( true );
        $self->builder( true ) unless $self->has_builder || $self->has_default;
        $self->is( ro );
    }

    if ( $self->has_builder and $self->has_default ) {
        croak "Attribute cannot have both default and builder.";
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
        elsif ( $self->cloner_method ) {
            require Mite::Shim;
            Mite::Shim::croak( 'Attributes with autoclone cannot have an lvalue accessor' );
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

    # Allow child class to switch from default to builder
    # or vice versa.
    if ( exists $args{builder} or exists $args{default} ) {
        delete $inherit{builder};
        delete $inherit{default};
    }

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

        if ( blessed $type and not $type->isa( 'Type::Tiny' ) ) {
            if ( $type->can( 'to_TypeTiny' ) ) {
                $type = $type->to_TypeTiny;
            }
            else {
                require Types::TypeTiny;
                $type = $type->Types::TypeTiny::to_TypeTiny;
            }
        }
        elsif ( not blessed $type ) {
            require Types::TypeTiny;
            $type = Types::TypeTiny::to_TypeTiny( $type );
        }
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

sub has_reference_default {
    my $self = shift;

    # We don't have a default
    return 0 unless $self->has_default;

    return HashRef->check( $self->default ) || ArrayRef->check( $self->default );
}

sub has_simple_default {
    my $self = shift;

    return 0 unless $self->has_default;

    return !ref $self->default;
}

sub _compile_check {
    my ( $self, $varname ) = @_;

    my $type  = $self->type;

    if ( $self->compiling_class
    and  $self->compiling_class->imported_functions->{blessed} ) {
        my $ctype = $type->find_constraining_type;

        if ( $ctype == Object ) {
            return "blessed( $varname )";
        }
        elsif ( $ctype->isa( 'Type::Tiny::Class' ) ) {
            return sprintf 'blessed( %s ) && %s->isa( %s )',
                $varname, $varname, $self->_q( $ctype->class );
        }
    }

    local $Type::Tiny::AvoidCallbacks = 1;
    return $type->inline_check( $varname );
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
    return $default if $self->default_is_trusted;
    my $type = $self->type or return $default;

    if ( $self->coerce ) {
        $default = $self->_compile_coercion( $default );
    }

    return sprintf 'do { my $default_value = %s; %s or %s( "Type check failed in default: %%s should be %%s", %s, %s ); $default_value }',
        $default, $self->_compile_check('$default_value'), $self->_function_for_croak, $self->_q($self->name), $self->_q($type->display_name);
}

sub _compile_default {
    my ( $self, $selfvar ) = @_;

    if ( $self->has_builder ) {
        return sprintf '%s->%s', $selfvar, $self->_expand_name( $self->builder );
    }
    elsif ( $self->has_coderef_default ) {
        my $var = $self->coderef_default_variable;
        return sprintf '%s->( %s )', $var, $selfvar;
    }
    elsif ( $self->has_inline_default ) {
        return ${ $self->default };
    }
    elsif ( $self->has_reference_default ) {
        return HashRef->check( $self->default ) ? '{}' : '[]';
    }
    elsif ( $self->has_simple_default and $self->type and $self->type == Bool ) {
        my $truthy = $self->compiling_class->imported_functions->{true}  ? 'true'  : '!!1';
        my $falsey = $self->compiling_class->imported_functions->{false} ? 'false' : '!!0';
        return $self->default ? $truthy : $falsey;
    }
    elsif ( $self->has_simple_default ) {
        return defined( $self->default ) ? $self->_q( $self->default ) : 'undef';
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

sub _compile_clone {
    my ( $self, $selfvar, $valuevar ) = @_;

    if ( 'CODE' eq ref $self->cloner_method ) {
        return sprintf '%s->_clone_%s( %s, %s )',
            $selfvar, $self->name, $self->_q( $self->name ), $valuevar;
    }

    if ( MethodNameTemplate->check( $self->cloner_method ) ) {
        return sprintf '%s->%s( %s, %s )',
            $selfvar, $self->_expand_name( $self->cloner_method ), $self->_q( $self->name ), $valuevar;
    }

    return "Storable::dclone( $valuevar )";
}

sub _sanitize_identifier {
    ( my $str = pop ) =~ s/([_\W])/$1 eq '_' ? '__' : sprintf('_%x', ord($1))/ge;
    $str;
}

sub compile_init {
    my ( $self, $selfvar, $argvar ) = @_;

    my @code;

    my $init_arg = $self->_expand_name( $self->init_arg );

    if ( defined $init_arg ) {

        if ( my @alias = $self->_all_aliases ) {
            my $new_argvar = "\$args_for_" . $self->_sanitize_identifier( $self->name );
            push @code, sprintf( 'my %s = {};', $new_argvar );
            push @code, sprintf 'for ( %s, %s ) { next unless exists %s->{$_}; %s->{%s} = %s->{$_}; last; }',
                $self->_q_init_arg, $self->_q( @alias ), $argvar, $new_argvar, $self->_q_init_arg, $argvar;
            $argvar = $new_argvar;
        }

        my $code;
        my $valuevar = sprintf '%s->{%s}', $argvar, $self->_q_init_arg;
        my $postamble = '';
        my $needs_check = 1;

        if ( $self->clone_on_write ) {
            push @code, sprintf '%s = %s if exists( %s );',
                $valuevar, $self->_compile_clone( $selfvar, $valuevar ), $valuevar;
        }

        if ( $self->has_default || $self->has_builder and not $self->lazy ) {
            if ( $self->default_is_trusted and my $type = $self->type ) {
                my $coerce_and_check;
                local $Type::Tiny::AvoidCallbacks = 1;
                if ( $type->has_coercion ) {
                    $coerce_and_check = sprintf 'do { my $coerced_value = %s; ( %s ) ? $coerced_value : %s( "Type check failed in constructor: %%s should be %%s", %s, %s ) }',
                        $self->_compile_coercion( $valuevar ), $type->inline_check( '$coerced_value' ), $self->_function_for_croak, $self->_q_init_arg, $self->_q( $type->display_name );
                }
                else {
                    $coerce_and_check = sprintf '( ( %s ) ? %s : %s( "Type check failed in constructor: %%s should be %%s", %s, %s ) )',
                        $type->inline_check( $valuevar ), $valuevar, $self->_function_for_croak, $self->_q_init_arg, $self->_q( $type->display_name );
                }
                $code .= sprintf 'do { my $value = exists( %s ) ? %s : %s; ',
                    $valuevar, $coerce_and_check, $self->_compile_default( $selfvar );
                $valuevar = '$value';
                $postamble = "}; $postamble";
                $needs_check = 0;
            }
            elsif ( $self->type ) {
                $code .= sprintf 'do { my $value = exists( %s ) ? %s : %s; ',
                    $valuevar, $valuevar, $self->_compile_default( $selfvar );
                $valuevar = '$value';
                $postamble = "}; $postamble";
            }
            else {
                $valuevar = sprintf '( exists( %s ) ? %s : %s )',
                    $valuevar, $valuevar, $self->_compile_default( $selfvar );
            }

            my $trigger_condition_code =
                ( $self->default_does_trigger and ! $self->lazy and $self->has_default || $self->has_builder )
                ? '; '
                : sprintf( ' if exists %s->{%s}; ', $argvar, $self->_q_init_arg );
            my $trigger_code = $self->trigger
                ? $self->_compile_trigger(
                    $selfvar,
                    sprintf( '%s->{%s}', $selfvar, $self->_q_name ),
                ) . $trigger_condition_code
                : '';
            $postamble = $trigger_code . $postamble;
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

        if ( $needs_check and my $type = $self->type ) {
            if ( $self->coerce ) {
                $code .= sprintf 'do { my $coerced_value = %s; ', $self->_compile_coercion( $valuevar );
                $valuevar = '$coerced_value';
                $postamble = "}; $postamble";
            }

            $code .= sprintf '%s or %s "Type check failed in constructor: %%s should be %%s", %s, %s; ',
                $self->_compile_check( $valuevar ),
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
        push @code, sprintf 'require Scalar::Util && Scalar::Util::weaken(%s->{%s}) if ref %s->{%s};',
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
            my $checked_default = $self->_compile_checked_default( '$_[0]' );
            if ( $self->default_does_trigger ) {
                $checked_default = sprintf 'do { my $default = %s; %s; $default }',
                    $checked_default, $self->_compile_trigger( '$_[0]', '$default' );
            }
            $code = sprintf '( exists($_[0]{%s}) ? $_[0]{%s} : ( $_[0]{%s} = %s ) )',
                $self->_q_name, $self->_q_name, $self->_q_name, $checked_default;
        }
        if ( $self->clone_on_read ) {
            $code = $self->_compile_clone( '$_[0]', $code );
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
        my $valuevar = '$_[1]';
        if ( my $type = $self->type ) {
            if ( $self->coerce ) {
                $code .= sprintf 'my $value = %s; ', $self->_compile_coercion($valuevar);
                $valuevar = '$value';
            }
            $code .= sprintf '%s or %s( "Type check failed in %%s: value should be %%s", %s, %s ); ',
                $self->_compile_check($valuevar), $self->_function_for_croak, $self->_q( $arg{label} // 'writer' ), $self->_q( $type->display_name );
        }
        if ( $self->clone_on_write ) {
            $code .= sprintf 'my $cloned = %s; ',
                $self->_compile_clone( '$_[0]', $valuevar );
            $valuevar = '$cloned';
        }
        $code .= sprintf '$_[0]{%s} = %s; ',
            $self->_q_name,
            $valuevar;
        if ( $self->trigger ) {
            $code .= ' ' . $self->_compile_trigger(
                '$_[0]',
                sprintf( '$_[0]{%s}', $self->_q_name ),
                '@oldvalue',
            ) . '; ';
        }
        if ( $self->weak_ref ) {
            $code .= sprintf 'require Scalar::Util && Scalar::Util::weaken($_[0]{%s}) if ref $_[0]{%s}; ',
                $self->_q_name, $self->_q_name;
        }
        $code .= '$_[0];';
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

    defined wantarray or %s( "This method cannot be called in void context" );
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

    # Class::XSAccessor can't do type checks, triggers, weaken, or cloning
    if ( $self->type or $self->weak_ref or $self->trigger or $self->cloner_method ) {
        delete $want_xs{writer};
        delete $want_xs{accessor};
    }

    # Class::XSAccessor can't do lazy builders checks or cloning
    if ( $self->lazy or $self->cloner_method ) {
        delete $want_xs{reader};
        delete $want_xs{accessor};
    }

    my $code = "# Accessors for $slot_name\n";
    $code .= '# ' . $self->definition_context_to_pretty_string. "\n";
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
        $code .= sprintf "# Aliases for %s\n", $self->name;
        $code .= '# ' . $self->definition_context_to_pretty_string. "\n";
        my $alias_target = $self->_expand_name( $self->$alias_is_for );
        for my $alias ( $self->_all_aliases ) {
            $code .= sprintf 'sub %s { shift->%s( @_ ) }' . "\n",
                $alias, $alias_target;
        }
        $code .= "\n";
    }

    if ( $self->has_handles ) {
        $code .= sprintf "# Delegated methods for %s\n", $self->name;
        $code .= '# ' . $self->definition_context_to_pretty_string. "\n";
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

sub definition_context_to_string {
    my $self = shift;
    my %context = ( %{ $self->definition_context }, @_ );

    return sprintf '{ %s }',
        join q{, },
        map sprintf( '%s => %s', $_, B::perlstring( $context{$_} ) ),
        sort keys %context;
}

sub definition_context_to_pretty_string {
    my $self = shift;
    my %context = ( %{ $self->definition_context }, @_ );

    ( $context{context} and $context{file} and $context{line} )
        or return '(unknown definition context)';

    return sprintf( '%s, file %s, line %d', $context{context}, $context{file}, $context{line} );
}

sub _compile_mop {
    my $self = shift;

    my $opts_string = '';
    my $accessors_code = '';
    my $opts_indent = "\n    ";

    $opts_string .= $opts_indent . '__hack_no_process_options => true,';
    if ( $self->compiling_class->isa('Mite::Class') ) {
        $opts_string .= $opts_indent . 'associated_class => $PACKAGE,';
    }
    else {
        $opts_string .= $opts_indent . 'associated_role => $PACKAGE,';
    }

    $opts_string .= $opts_indent . 'definition_context => ' . $self->definition_context_to_string . ',';

    {
        my %translate = ( ro => 'ro', rw => 'rw', rwp => 'ro', bare => 'bare', lazy => 'ro'  );
        $opts_string .= $opts_indent . sprintf( 'is => "%s",', $translate{$self->is} || 'bare' );
    }

    $opts_string .= $opts_indent . sprintf( 'weak_ref => %s,', $self->weak_ref ? 'true' : 'false' );

    {
        my $init_arg = $self->init_arg;
        if ( defined $init_arg ) {
            $opts_string .= $opts_indent . sprintf( 'init_arg => %s,', $self->_q_init_arg );
            $opts_string .= $opts_indent . sprintf( 'required => %s,', $self->required ? 'true' : 'false' );
        }
        else {
            $opts_string .= $opts_indent . 'init_arg => undef,';
        }
    }

    if ( my $type = $self->type ) {
        # Easy case...
        if ( $type->name and $type->library ) {
            $opts_string .= $opts_indent . sprintf( 'type_constraint => do { require %s; %s::%s() },', $type->library, $type->library, $type->name );
        }
        elsif ( $type->isa( 'Type::Tiny::Union' ) and List::Util::all { $_->name and $_->library } @$type ) {
            my $requires = join q{; }, List::Util::uniq( map sprintf( 'require %s', $_->library ), @$type );
            my $union    = join q{ | }, List::Util::uniq( map sprintf( '%s::%s()', $_->library, $_->name ), @$type );
            $opts_string .= $opts_indent . sprintf( 'type_constraint => do { %s; %s },', $requires, $union );
        }
        elsif ( $type->is_parameterized
        and 1 == @{ $type->parameters }
        and $type->parent->name
        and $type->parent->library
        and $type->type_parameter->name
        and $type->type_parameter->library ) {
            my $requires = join q{; }, List::Util::uniq( map sprintf( 'require %s', $_->library ), $type->parent, $type->type_parameter );
            my $ptype    = sprintf( '%s::%s()->parameterize( %s::%s() )', $type->parent->library, $type->parent->name, $type->type_parameter->library, , $type->type_parameter->name );
            $opts_string .= $opts_indent . sprintf( 'type_constraint => do { %s; %s },', $requires, $ptype );
        }
        else {
            local $Type::Tiny::AvoidCallbacks = 1;
            local $Type::Tiny::SafePackage = '';
            $opts_string .= $opts_indent . 'type_constraint => do {';
            $opts_string .= $opts_indent . '    require Type::Tiny;';
            $opts_string .= $opts_indent . '    my $TYPE = Type::Tiny->new(';
            $opts_string .= $opts_indent . sprintf '        display_name => %s,', B::perlstring( $type->display_name );
            $opts_string .= $opts_indent . sprintf '        constraint   => sub { %s },', $type->inline_check( '$_' );
            $opts_string .= $opts_indent . '    );';
            if ( $type->has_coercion ) {
                $opts_string .= $opts_indent . '    require Types::Standard;';
                $opts_string .= $opts_indent . '    $TYPE->coercion->add_type_coercions(';
                $opts_string .= $opts_indent . '        Types::Standard::Any(),';
                $opts_string .= $opts_indent . sprintf '        sub { %s },', $type->coercion->inline_coercion( '$_' );
                $opts_string .= $opts_indent . '    );';
                $opts_string .= $opts_indent . '    $TYPE->coercion->freeze;';
            }
            $opts_string .= $opts_indent . '    $TYPE;';
            $opts_string .= $opts_indent . '},';
        }
        if ( $type->has_coercion and $self->coerce ) {
           $opts_string .= $opts_indent . 'coerce => true,';
        }
    }

    for my $accessor ( qw/ reader writer accessor predicate clearer / ) {
        my $name = $self->_expand_name( $self->$accessor );
        defined $name or next;
        my $qname = $self->_q( $name );
        my $dfnctx = $self->definition_context_to_string( description => sprintf( '%s %s::%s', $accessor, $self->compiling_class->name, $name ) );

        $opts_string .= $opts_indent . sprintf( '%s => %s,', $accessor, $qname );

        $accessors_code .= sprintf <<'CODE', $accessor, $self->_q_name, $qname, $self->compiling_class->name, $name, $self->_q($self->compiling_class->name), $dfnctx, $self->_q_name;
{
    my $ACCESSOR = Moose::Meta::Method::Accessor->new(
        accessor_type => '%s',
        attribute => $ATTR{%s},
        name => %s,
        body => \&%s::%s,
        package_name => %s,
        definition_context => %s,
    );
    $ATTR{%s}->associate_method( $ACCESSOR );
    $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
}
CODE
    }

    for my $accessor ( qw/ lvalue local_writer / ) {
        my $name = $self->_expand_name( $self->$accessor );
        defined $name or next;
        my $qname = $self->_q( $name );

        $accessors_code .= sprintf <<'CODE', $qname, $self->compiling_class->name, $name, $self->_q($self->compiling_class->name), $self->_q_name;
{
    my $ACCESSOR = Moose::Meta::Method->_new(
        name => %s,
        body => \&%s::%s,
        package_name => %s,
    );
    $ATTR{%s}->associate_method( $ACCESSOR );
    $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
}
CODE
    }

    {
        my $h = $self->handles || {};
        my $hstring = '';
        for my $delegated ( sort keys %$h ) {
            my $name = $self->_expand_name( $delegated );
            my $qname = $self->_q( $name );
            my $target = $h->{$delegated};
            my $qtarget = $self->_q( $target );
            $hstring .= ", $qname => $qtarget";

            $accessors_code .= sprintf <<'CODE', $qname, $self->_q_name, $qtarget, $self->compiling_class->name, $name, $self->_q($self->compiling_class->name), $self->_q_name;
{
    my $DELEGATION = Moose::Meta::Method::Delegation->new(
        name => %s,
        attribute => $ATTR{%s},
        delegate_to_method => %s,
        curried_arguments => [],
        body => \&%s::%s,
        package_name => %s,
    );
    $ATTR{%s}->associate_method( $DELEGATION );
    $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
}
CODE
        }

        if ( $hstring ) {
            $hstring =~ s/^, //;
            $opts_string .= $opts_indent . "handles => { $hstring },";
        }
    }

    {
        my @aliases = $self->_all_aliases;
        for my $name ( sort @aliases ) {
            my $qname = $self->_q( $name );

            $accessors_code .= sprintf <<'CODE', $qname, $self->compiling_class->name, $name, $self->_q($self->compiling_class->name), $self->_q_name;
{
    my $ALIAS = Moose::Meta::Method->_new(
        name => %s,
        body => \&%s::%s,
        package_name => %s,
    );
    $ATTR{%s}->associate_method( $ALIAS );
    $PACKAGE->add_method( $ALIAS->name, $ALIAS );
}
CODE
        }
    }

    if ( my $builder = $self->_expand_name( $self->builder ) ) {
        $opts_string .= $opts_indent . sprintf( 'builder => %s,', $self->_q( $builder ) );
    }
    elsif ( $self->has_inline_default or $self->has_reference_default ) {
        $opts_string .= $opts_indent . sprintf( 'default => sub { %s },', $self->_compile_default );
    }
    elsif ( $self->has_coderef_default ) {
        $opts_string .= $opts_indent . sprintf( 'default => %s,', $self->coderef_default_variable );
    }
    elsif ( $self->has_default ) {
        $opts_string .= $opts_indent . sprintf( 'default => %s,', $self->_compile_default );
    }
    if ( $self->has_default or $self->has_builder ) {
        $opts_string .= $opts_indent . sprintf( 'lazy => %s,', $self->lazy ? 'true' : 'false' );
    }

    if ( my $trigger = $self->_expand_name( $self->trigger ) ) {
        $opts_string .= $opts_indent . sprintf( 'trigger => sub { shift->%s( @_ ) },', $trigger );
    }

    if ( $self->has_documentation ) {
        $opts_string .= $opts_indent . sprintf( 'documentation => %s,', $self->_q( $self->documentation ) );
    }

    if ( not $self->compiling_class->isa( 'Mite::Class' ) ) {
        $accessors_code = sprintf "delete \$ATTR{%s}{original_options}{\$_} for qw( associated_role );\n",
            $self->_q_name;
    }

    $opts_string .= "\n";
    return sprintf <<'CODE', $self->_q_name, $self->compiling_class->_mop_attribute_metaclass, $self->_q_name, $opts_string, $accessors_code, $self->_q_name;
$ATTR{%s} = %s->new( %s,%s);
%sdo {
	no warnings 'redefine';
	local *Moose::Meta::Attribute::install_accessors = sub {};
	$PACKAGE->add_attribute( $ATTR{%s} );
};
CODE
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
