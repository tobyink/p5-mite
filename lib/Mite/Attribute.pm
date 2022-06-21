package Mite::Attribute;
use Mite::MyMoo;

has default =>
  is            => rw,
  isa           => Maybe[Str|Ref],
  predicate     => 'has_default';

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
  isa           => Enum[ ro, rw, 'bare' ],
  default       => 'bare';

has name =>
  is            => rw,
  isa           => Str->where('length($_) > 0'),
  required      => true;

sub clone {
    my ( $self, %args ) = ( shift, @_ );

    $args{name} //= $self->name;
    $args{is}   //= $self->is;

    # Because undef is a valid default
    $args{default} = $self->default
        if !exists $args{default} and $self->has_default;

    return $self->new( %args );
}

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

sub compile_init {
    my ( $self, $selfvar, $argvar ) = @_;

    if ( $self->has_default ) {
        return sprintf '%s->{%s} = exists(%s->{%s}) ? delete(%s->{%s}) : %s;',
            $selfvar, $self->name,
            $argvar,  $self->name,
            $argvar,  $self->name,
            $self->_compile_default( $selfvar );
    }
    else {
        return sprintf '%s->{%s} = delete(%s->{%s}) if exists(%s->{%s});',
            $selfvar, $self->name,
            $argvar,  $self->name,
            $argvar,  $self->name;
    }
}

sub compile {
    my $self = shift;

    my $perl_method = $self->is eq 'rw' ? '_compile_rw_perl'    :
                      $self->is eq 'ro' ? '_compile_ro_perl'    :
                                          '_empty'              ;

    my $xs_method   = $self->is eq 'rw' ? '_compile_rw_xs'      :
                      $self->is eq 'ro' ? '_compile_ro_xs'      :
                                          '_empty'              ;

    return sprintf <<'CODE', $self->$xs_method, $self->$perl_method;
if( !$ENV{MITE_PURE_PERL} && eval { require Class::XSAccessor } ) {
%s
}
else {
%s
}
CODE
}

sub _compile_rw_xs {
    my $self = shift;

    my $name = $self->name;

    return <<"CODE";
Class::XSAccessor->import(
    accessors => { q[$name] => q[$name] }
);
CODE

}

sub _compile_rw_perl {
    my $self = shift;

    my $name = $self->name;

    return sprintf <<'CODE', $name, $name, $name;
*%s = sub {
    # This is hand optimized.  Yes, even adding
    # return will slow it down.
    @_ > 1 ? $_[0]->{ q[%s] } = $_[1]
           : $_[0]->{ q[%s] };
}
CODE

}

sub _compile_ro_xs {
    my $self = shift;

    my $name = $self->name;

    return <<"CODE";
Class::XSAccessor->import(
    getters => { q[$name] => q[$name] }
);
CODE
}

sub _compile_ro_perl {
    my $self = shift;

    my $name = $self->name;
    return sprintf <<'CODE', $name, $name, $name;
*%s = sub {
    # This is hand optimized.  Yes, even adding
    # return will slow it down.
    @_ > 1 ? require Carp && Carp::croak("%s is a read-only attribute of @{[ref $_[0]]}")
           : $_[0]->{ q[%s] };
};
CODE
}

1;
