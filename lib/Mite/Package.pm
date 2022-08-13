use 5.010001;
use strict;
use warnings;

package Mite::Package;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010004';

has name =>
  is            => ro,
  isa           => ValidClassName,
  required      => true;

has shim_name =>
  is            => rw,
  isa           => ValidClassName,
  lazy          => true,
  builder       => sub {
    my $self = shift;
    eval { $self->project->config->data->{shim} } // 'Mite::Shim'
  };

has source =>
  is            => rw,
  isa           => MiteSource,
  # avoid a circular dep with Mite::Source
  weak_ref      => true;

has imported_functions =>
  is            => ro,
  isa           => Map[ MethodName, Str ],
  builder       => sub { {} };

has imported_keywords =>
  is            => ro,
  isa           => Map[ MethodName, Str ],
  builder       => sub { {} };

has arg =>
  is            => rw,
  default       => {};

sub kind { 'package' }

sub BUILD {
    my $self = shift;

    require Type::Registry;
    my $reg = 'Type::Registry'->for_class( $self->name );
    $reg->add_types( 'Types::Standard' );
    $reg->add_types( 'Types::Common::Numeric' );
    $reg->add_types( 'Types::Common::String' );

    my $library = eval { $self->project->config->data->{types} };
    $reg->add_types( $library ) if $library;
}

sub project {
    my $self = shift;

    return $self->source->project;
}

sub inject_mite_functions {
    my ( $self, $file, $arg ) = ( shift, @_ );

    my $requested = sub { $arg->{$_[0]} ? 1 : $arg->{'!'.$_[0]} ? 0 : $arg->{'-all'} ? 1 : $_[1]; };
    my $shim      = $self->shim_name;
    my $package   = $self->name;
    my $ctxt      = $shim->can( '_definition_context' );

    no strict 'refs';
    ${ $package .'::USES_MITE' } = ref( $self );
    ${ $package .'::MITE_SHIM' } = $shim;

    my $want_bool = $requested->( '-bool', 0 );
    my $want_is   = $requested->( '-is',   0 );
    for my $f ( qw/ true false / ) {
        next unless $requested->( $f, $want_bool );
        *{"$package\::$f"} = \&{"$shim\::$f"};
        $self->imported_functions->{$f} = "$shim\::$f";
    }
    for my $f ( qw/ ro rw rwp lazy bare / ) {
        next unless $requested->( $f, $want_is );
        *{"$package\::$f"} = \&{"$shim\::$f"};
        $self->imported_functions->{$f} = "$shim\::$f";
    }
    for my $f ( qw/ carp croak confess guard STRICT / ) {
        next unless $requested->( $f, false );
        *{"$package\::$f"} = \&{"$shim\::$f"};
        $self->imported_functions->{$f} = "$shim\::$f";
    }
    if ( $requested->( blessed => false ) ) {
        require Scalar::Util;
        *{"$package\::blessed"} = \&Scalar::Util::blessed;
        $self->imported_functions->{blessed} = "Scalar::Util::blessed";
    }
}

sub autolax {
    my $self = shift;

    return undef
        if not eval { $self->project->config->data->{autolax} };

    return $self->imported_functions->{STRICT}
        ? 'STRICT'
        : sprintf( '%s::STRICT', $self->project->config->data->{shim} );
}

for my $function ( qw/ carp croak confess / ) {
    no strict 'refs';
    *{"_function_for_$function"} = sub {
        my $self = shift;
        return $function
            if $self->imported_functions->{$function};
        return sprintf '%s::%s', $self->shim_name, $function
            if $self->shim_name;
        $function eq 'carp' ? 'warn sprintf' : 'die sprintf';
    };
}

sub compile {
    my $self = shift;

    my $code = join "\n",
        '{',
        map( $self->$_, $self->compilation_stages ),
        '1;',
        '}';

    #::diag $code if main->can('diag');
    return $code;
}

sub _compile_meta {
    my ( $self, $classvar, $selfvar, $argvar, $metavar ) = @_;
    return sprintf '( $Mite::META{%s} ||= %s->__META__ )',
        $classvar, $classvar;
}

sub compilation_stages {
    return qw(
        _compile_package
        _compile_pragmas
        _compile_uses_mite
        _compile_imported_keywords
        _compile_imported_functions
        _compile_meta_method
    );
}

sub _compile_package {
    my $self = shift;

    return "package @{[ $self->name ]};";
}

sub _compile_pragmas {
    my $self = shift;

    return <<'CODE';
use strict;
use warnings;
no warnings qw( once void );
CODE
}

sub _compile_uses_mite {
    my $self = shift;

    my @code = sprintf 'our $USES_MITE = %s;', B::perlstring( ref($self) );
    if ( $self->shim_name ) {
        push @code, sprintf 'our $MITE_SHIM = %s;', B::perlstring( $self->shim_name );
    }
    push @code, sprintf 'our $MITE_VERSION = %s;', B::perlstring( $self->VERSION );
    join "\n", @code;
}

sub _compile_imported_keywords {
    my $self = shift;

    my %func = %{ $self->imported_keywords or {} } or return;
    my @keywords = sort keys %func;
    my $keyword_slots = join q{, }, map "*$_", @keywords;
    my $coderefs = join "\n", map "            $func{$_},", @keywords;

    return sprintf <<'CODE', B::perlstring( $self->shim_name ), B::perlstring( $self->name ), $keyword_slots, $self->shim_name, $coderefs;
# Mite keywords
BEGIN {
    my ( $SHIM, $CALLER ) = ( %s, %s );
    ( %s ) = do {
        package %s;
        no warnings 'redefine';
        (
%s
        );
    };
};
CODE
}

sub _compile_imported_functions {
    my $self = shift;
    my %func = %{ $self->imported_functions } or return;

    return join "\n",
        '# Mite imports',
        'BEGIN {',
        ( $func{blessed} ? '    require Scalar::Util;' : () ),
        map(
            sprintf( '    *%s = \&%s;',  $_, $func{$_} ),
            sort keys %func
        ),
        '};',
        '';
}

sub _compile_meta_method {
    my $self = shift;

    my $code = <<'CODE';
# Gather metadata for constructor and destructor
sub __META__ {
    no strict 'refs';
    no warnings 'once';
    my $class      = shift; $class = ref($class) || $class;
    my $linear_isa = mro::get_linear_isa( $class );
    return {
        BUILD => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::BUILD" } reverse @$linear_isa
        ],
        DEMOLISH => [
            map { ( *{$_}{CODE} ) ? ( *{$_}{CODE} ) : () }
            map { "$_\::DEMOLISH" } @$linear_isa
        ],
        HAS_BUILDARGS => $class->can('BUILDARGS'),
        HAS_FOREIGNBUILDARGS => $class->can('FOREIGNBUILDARGS'),
    };
}
CODE

    if ( eval { $self->project->config->data->{mop} } ) {
        $code .= sprintf <<'CODE', $self->project->config->data->{mop};

# Moose-compatibility method
sub meta {
    require %s;
    Moose::Util::find_meta( ref $_[0] or $_[0] );
}
CODE
    }

    return $code;
}

1;
