use 5.010001;
use strict;
use warnings;

package Mite::Signature;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.013000';

has class =>
  is            => ro,
  isa           => MitePackage,
  weak_ref      => true;

has compiling_class =>
  init_arg      => undef,
  is            => rw,
  isa           => MitePackage,
  local_writer  => true;

has method_name =>
  is            => ro,
  isa           => Str,
  required      => true;

has named =>
  is            => ro,
  isa           => ArrayRef->plus_coercions( HashRef, q([%$_]) ),
  predicate     => 'is_named';

has positional =>
  is            => ro,
  isa           => ArrayRef,
  alias         => 'pos',
  predicate     => 'is_positional';

has method =>
  is            => 'ro',
  isa           => Bool,
  default       => true;

has head =>
  is            => lazy,
  isa           => ArrayRef | Int,
  builder       => sub { shift->method ? [ Defined, { name => 'invocant' } ] : [] };

has tail =>
  is            => ro,
  isa           => ArrayRef | Int;

has named_to_list =>
  is            => ro,
  isa           => Bool | ArrayRef,
  default       => false;

has compiler =>
  init_arg      => undef,
  is            => lazy,
  isa           => Object,
  builder       => true,
  handles       => [ qw( has_head has_tail has_slurpy ) ];

has should_bless =>
  init_arg      => undef,
  is            => lazy,
  isa           => Bool,
  builder       => sub { !!( $_[0]->is_named && !$_[0]->named_to_list ) };

sub BUILD {
    my $self = shift;

    croak 'Method cannot be both named and positional'
        if $self->is_named && $self->is_positional;
}

sub autolax {
    my $self = shift;

    my $class = $self->compiling_class || $self->class;
    return if not $class;
    return if not eval { $class->project->config->data->{autolax} };
    return sprintf '%s::STRICT', $class->project->config->data->{shim};
}

sub _build_compiler {
    my $self = shift;

    local $Type::Tiny::AvoidCallbacks = 1;
    local $Type::Tiny::SafePackage    = sprintf( 'package %s;', $self->class->shim_name );

    require Mite::Signature::Compiler;
    my $c = 'Mite::Signature::Compiler'->new_from_compile(
        $self->is_named ? 'named' : 'positional',
        {
            package        => $self->class->name,
            subname        => $self->method_name,
            ( $self->head ? ( head => $self->head ) : () ),
            ( $self->tail ? ( tail => $self->tail ) : () ),
            named_to_list  => $self->named_to_list,
            strictness     => scalar( $self->autolax // 1 ),
            goto_next      => true,
            mite_signature => $self,
            $self->should_bless
                ? ( bless => sprintf '%s::__NAMED_ARGUMENTS__::%s', $self->class->name, $self->method_name )
                : (),
        },
        $self->is_named
            ? @{ $self->named }
            : @{ $self->positional },
    );

    $c->coderef;

    if ( keys %{ $c->coderef->{env} } ) {
        croak "Signature could not be inlined properly; bailing out";
    }

    return $c;
}

sub _compile_coderef {
    my $self = shift;

    if ( $self->compiling_class and $self->compiling_class != $self->class ) {
        return sprintf( '$%s::SIGNATURE_FOR{%s}', $self->class->name, B::perlstring( $self->method_name ) );
    }

    my $code = $self->compiler->coderef->code;
    $code =~ s/^\s+|\s+$//gs;

    return $code;
}

sub _compile_support {
    my $self = shift;

    if ( $self->compiling_class and $self->compiling_class != $self->class ) {
        return;
    }

    return unless $self->should_bless;
    return $self->compiler->make_class_pp_code;
}

sub clone {
    my ( $self, %args ) = @_;

    # alias
    $args{positional} = $args{pos} if exists $args{pos};

    if ( $self->has_slurpy and $args{positional} ) {
        croak "Cannot add new positional parameters when extending an existing signature with a slurpy parameter";
    }
    elsif ( $self->has_slurpy and $args{named} ) {
        croak "Cannot add new named parameters when extending an existing signature with a slurpy parameter";
    }
    elsif ( $self->is_named and $args{positional} ) {
        croak "Cannot add positional parameters when extending an existing signature which has named parameters";
    }
    elsif ( !$self->is_named and $args{named} ) {
        croak "Cannot add named parameters when extending an existing signature which has positional parameters";
    }

    if ( $args{positional} ) {
        $args{positional} = [ @{ $self->positional }, @{ $args{positional} } ];
    }

    if ( $args{named} ) {
        $args{named} = [ @{ $self->named }, @{ $args{named} } ];
    }

    my %new_args = ( %$self, %args );

    # Rebuild these
    delete $new_args{compiler};
    delete $new_args{should_bless};

    return __PACKAGE__->new( %new_args );
}

1;
