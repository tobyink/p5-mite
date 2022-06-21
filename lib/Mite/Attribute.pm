package Mite::Attribute;
use Mite::MyMoo;

has default =>
  is            => rw,
  isa           => Maybe[Str|Ref],
  predicate     => 'has_default';

has init_arg =>
  is            => rw,
  isa           => Str|Undef,
  default       => sub { shift->name },
  lazy          => true;

has required =>
  is            => rw,
  isa           => Bool,
  default       => false;

has coderef_default_variable =>
  is            => rw,
  isa           => Str,
  lazy          => true,     # else $self->name might not be set
  default       => sub {
      my $self = shift;
      # This must be coordinated with Mite.pm
      return sprintf '$__%s_DEFAULT__', $self->name;
  };

has is =>
  is            => rw,
  isa           => Enum[ ro, rw, rwp, 'bare' ],
  default       => 'bare';

has name =>
  is            => rw,
  isa           => Str->where('length($_) > 0'),
  required      => true;

has [ 'reader', 'writer', 'accessor', 'clearer', 'predicate' ] =>
  is            => rw,
  isa           => Str->where('length($_) > 0') | Undef,
  builder       => true,
  lazy          => true;

# Not actually supported yet
has builder =>
    is            => rw,
    isa           => Str->where('length($_) > 0') | CodeRef | Undef,

my @method_name_generator = (
    { # public
        reader      => sub { "get_$_" },
        writer      => sub { "set_$_" },
        accessor    => sub { $_ },
        clearer     => sub { "clear_$_" },
        predicate   => sub { "has_$_" },
        builder     => sub { "_build_$_" },
    },
    { # private
        reader      => sub { "_get_$_" },
        writer      => sub { "_set_$_" },
        accessor    => sub { $_ },
        clearer     => sub { "_clear_$_" },
        predicate   => sub { "_has_$_" },
        builder     => sub { "_build_$_" },
    },
);

sub BUILD {
    my $self = shift;

    croak "Required attribute with no init_arg"
        if $self->required && !defined $self->init_arg;

    for my $property ( 'reader', 'writer', 'accessor', 'clearer', 'predicate', 'builder' ) {
        my $name = $self->$property;
        if ( defined $name and $name eq 1 ) {
            my $gen = $method_name_generator[$self->is_private]{$property};
            local $_ = $self->name;
            my $newname = $gen->( $_ );
            $self->$property( $newname );
        }
    }
}

sub clone {
    my ( $self, %args ) = ( shift, @_ );

    $args{name} //= $self->name;
    $args{is}   //= $self->is;

    # Because undef is a valid default
    $args{default} = $self->default
        if !exists $args{default} and $self->has_default;

    return $self->new( %args );
}

sub is_private {
    ( shift->name =~ /^_/ ) ? 1 : 0;
}

sub _build_reader {
    my $self = shift;
    ( $self->is eq 'ro' || $self->is eq 'rwp' )
        ? $self->name
        : undef;
}

sub _build_writer {
    my $self = shift;
    $self->is eq 'rwp'
        ? sprintf( '_set_%s', $self->name )
        : undef;
}

sub _build_accessor {
    my $self = shift;
    $self->is eq 'rw'
        ? $self->name
        : undef;
}

sub _build_predicate { undef; }

sub _build_clearer { undef; }

sub has_dataref_default {
    my $self = shift;

    # We don't have a default
    return 0 unless $self->has_default;

    # It's not a reference.
    return 0 if $self->has_simple_default;

    return ref $self->default ne 'CODE';
}

sub has_coderef_default {
    my $self = shift;

    # We don't have a default
    return 0 unless $self->has_default;

    return ref $self->default eq 'CODE';
}

sub has_simple_default {
    my $self = shift;

    return 0 unless $self->has_default;

    # Special case for regular expressions, they do not need to be dumped.
    return 1 if ref $self->default eq 'Regexp';

    return !ref $self->default;
}

sub _empty {
    my $self = shift;

    return ';';
}

sub _compile_default {
    my ( $self, $selfvar ) = @_;

    if ( $self->has_coderef_default ) {
        my $var = $self->coderef_default_variable;
        return sprintf 'do { our %s; %s->(%s) }',
          $var, $var, $selfvar;
    }
    elsif ( $self->has_simple_default ) {
        require B;
        return defined( $self->default ) ? B::perlstring( $self->default ) : 'undef';
    }

    # should never get here
    return 'undef';
}

sub _compile_required_error {
    my $self = shift;

    return sprintf 'do { require Carp; Carp::croak("Missing key in contructor: %s") }',
        $self->init_arg;
}

sub compile_init {
    my ( $self, $selfvar, $argvar ) = @_;

    my $init_arg = $self->init_arg;

    if ( $self->has_default and not defined $init_arg ) {
        return sprintf '%s->{%s} = %s;',
            $selfvar, $self->name,
            $self->_compile_default( $selfvar );
    }

    if ( $self->has_default ) {
        return sprintf '%s->{%s} = exists(%s->{%s}) ? delete(%s->{%s}) : %s;',
            $selfvar, $self->name,
            $argvar,  $init_arg,
            $argvar,  $init_arg,
            $self->_compile_default( $selfvar );
    }

    if ( defined $init_arg ) {
        if ( $self->required ) {
            return sprintf '%s->{%s} = exists(%s->{%s}) ? delete(%s->{%s}) : %s;',
                $selfvar, $self->name,
                $argvar,  $init_arg,
                $argvar,  $init_arg,
                $self->_compile_required_error;
        }
        return sprintf '%s->{%s} = delete(%s->{%s}) if exists(%s->{%s});',
            $selfvar, $self->name,
            $argvar,  $init_arg,
            $argvar,  $init_arg;
    }
}

sub compile {
    my $self = shift;

    return sprintf <<'CODE', $self->_compile_xs, $self->_compile_perl;
if( !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor } ) {
%s
}
else {
%s
}
CODE
}

my %code_template = (
    reader => sub {
        my $slot_name = shift->name;
        sprintf '@_ > 1 ? require Carp && Carp::croak("%s is a read-only attribute of @{[ref $_[0]]}") : $_[0]->{ q[%s] }',
            $slot_name, $slot_name;
    },
    writer => sub {
        my $slot_name = shift->name;
        sprintf '$_[0]->{ q[%s] } = $_[1];',
            $slot_name;
    },
    accessor => sub {
        my $slot_name = shift->name;
        sprintf '@_ > 1 ? $_[0]->{ q[%s] } = $_[1] : $_[0]->{ q[%s] }',
            $slot_name, $slot_name;
    },
    clearer => sub {
        my $slot_name = shift->name;
        sprintf 'delete $_[0]->{ q[%s] }; $_[0];',
            $slot_name;
    },
    predicate => sub {
        my $slot_name = shift->name;
        sprintf 'exists $_[0]->{ q[%s] };',
            $slot_name;
    },
);

sub _compile_xs {
    my $self = shift;

    my $slot_name = $self->name;

    my %options = (
        reader    => 'getters',
        writer    => 'setters',
        accessor  => 'accessors',
        predicate => 'exists_predicates',
    );

    my $xs = 0;
    my $code = "Class::XSAccessor->import(\n";
    for my $property ( 'reader', 'writer', 'accessor', 'predicate' ) {
        my $method_name = $self->$property;
        next unless defined $method_name;
        my $option = $options{$property};
        $code .= "    $option => { q[$method_name] => q[$slot_name] },\n";
        $xs++;
    }
    $code .= ");\n";
    $code = '' unless $xs;

    # Class::XSAccessor doesn't have clearers
    if ( my $clearer = $self->clearer ) {
        $code .= sprintf '*%s = sub { %s };' . "\n",
            $clearer, $code_template{clearer}->($self);
    }

    return $code;
}

sub _compile_perl {
    my $self = shift;

    my $slot_name = $self->name;

    my $code = '';

    for my $property ( 'reader', 'writer', 'accessor', 'predicate', 'clearer' ) {
        my $method_name = $self->$property;
        next unless defined $method_name;
        $code .= sprintf "    *%s = sub { %s };\n",
            $method_name, $code_template{$property}->($self);
    }

    return $code;
}

1;
