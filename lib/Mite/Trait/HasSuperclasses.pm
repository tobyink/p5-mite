use 5.010001;
use strict;
use warnings;

package Mite::Trait::HasSuperclasses;
use Mite::Miteception -role, -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010001';

# Super classes as class names
has extends =>
  is            => bare,
  accessor      => 'superclasses',
  isa           => ArrayRef[ValidClassName],
  default       => sub { [] },
  default_does_trigger => true,
  trigger       => sub {
    my $self = shift;

    return if !$self->name; # called from constructor

    # Set up our @ISA so we can use mro to calculate the class hierarchy
    $self->_set_isa;

    # Allow $self->parents to recalculate itself
    $self->_clear_parents;
  };

has superclass_args =>
  is            => rw,
  isa           => Map[ NonEmptyStr, HashRef|Undef ],
  builder       => sub { {} };

# Super classes as Mite::Classes populated from $self->superclasses
has parents =>
  is            => ro,
  isa           => ArrayRef[MiteClass],
  # Build on demand to allow the project to load all the classes first
  lazy          => true,
  builder       => '_build_parents',
  clearer       => '_clear_parents';

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

sub handle_extends_keyword {
    my $self = shift;

    my ( @extends, %extends_args );
    while ( @_ ) {
        my $class = shift;
        my $args  = Str->check( $_[0] ) ? undef : shift;
        push @extends, $class;
        $extends_args{$class} = $args;
    }
    $self->superclasses( \@extends );
    $self->superclass_args( \%extends_args );

    return;
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
    eval "require $parent_name;";
    $parent = $project->class($parent_name);
    return $parent if $parent;

    return;
}

around compilation_stages => sub {
    my ( $next, $self ) = ( shift, shift );
    my @stages = $self->$next( @_ );
    push @stages, '_compile_extends';
    return @stages;
};

around _compile_meta_method => sub {
    my ( $next, $self ) = ( shift, shift );

    # Check if we are inheriting from a Mite class in this project
    my $inherit_from_mite = do {
        # First parent
        my $first_isa = do {
            my @isa = $self->linear_isa;
            shift @isa;
            shift @isa;
        };
        !! ( $first_isa and $self->_get_parent( $first_isa ) );
    };

    return '' if $inherit_from_mite;

    return $self->$next( @_ );
};

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

    my $version_tests = join "\n\t",
        map { sprintf '%s->VERSION( %s );',
            B::perlstring( $_ ),
            B::perlstring( $self->superclass_args->{$_}{'-version'} )
        }
        grep {
            $self->superclass_args->{$_}
            and $self->superclass_args->{$_}{'-version'}
        }
        @$extends;

    my $isa_list = join ", ", map B::perlstring($_), @$extends;

    return <<"END";
BEGIN {
    $require_list
    $version_tests
    use mro 'c3';
    our \@ISA;
    push \@ISA, $isa_list;
}
END
}

1;
