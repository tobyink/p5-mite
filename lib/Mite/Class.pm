package Mite::Class;
use Mite::MyMoo;

use Path::Tiny;
use mro;

has attributes =>
  is            => ro,
  isa           => HashRef[InstanceOf['Mite::Attribute']],
  default       => sub { {} };

# Super classes as class names
has extends =>
  is            => rw,
  isa           => ArrayRef[Str],
  default       => sub { [] },
  trigger       => sub {
      my $self = shift;

      # Set up our @ISA so we can use mro to calculate the class hierarchy
      $self->_set_isa;

      # Allow $self->parents to recalculate itself
      $self->_clear_parents;
  };

# Super classes as Mite::Classes populated from $self->extends
has parents =>
  is            => ro,
  isa           => ArrayRef[InstanceOf['Mite::Class']],
  # Build on demand to allow the project to load all the classes first
  lazy          => true,
  builder       => '_build_parents',
  clearer       => '_clear_parents';

has name =>
  is            => ro,
  isa           => Str,
  required      => true;

has source =>
  is            => rw,
  isa           => InstanceOf['Mite::Source'],
  # avoid a circular dep with Mite::Source
  weak_ref      => true;

sub project {
    my $self = shift;

    return $self->source->project;
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
    @{$name.'::ISA'} = @{$self->extends};

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

    return map { $project->class($_) } $self->linear_isa;
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

    my $extends = $self->extends;
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
    require $parent;
    $parent = $project->class($parent_name);
    return $parent if $parent;

    croak <<"ERROR";
$parent loaded but is not a Mite class.
Extending non-Mite classes not yet supported.
Sorry.
ERROR
}

sub add_attributes {
    state $sig = sig_pos( Object, slurpy ArrayRef[InstanceOf['Mite::Attribute']] );
    my ( $self, $attributes ) = &$sig;

    for my $attribute (@$attributes) {
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

    my $parent_attr = $self->parents_attributes->{$name};
    croak(sprintf <<'ERROR', $name, $self->name) unless $parent_attr;
Could not find an attribute by the name of '%s' to inherit from in %s
ERROR

    $self->add_attribute($parent_attr->clone(%attr_args));

    return;
}


sub compile {
    my $self = shift;

    return join "\n", '{',
                      $self->_compile_package,
                      $self->_compile_pragmas,
                      $self->_compile_extends,
                      $self->_compile_new,
                      $self->_compile_attributes,
                      '1;',
                      '}';
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
CODE
}

sub _compile_extends {
    my $self = shift;

    my $extends = $self->extends;
    return '' unless @$extends;

    my $source = $self->source;

    my $require_list = join "\n\t",
                            map  { "require $_;" }
                            # Don't require a class from the same source
                            grep { !$source || !$source->has_class($_) }
                            @$extends;

    my $isa_list     = join ", ", map { "q[$_]" } @$extends;

    return <<"END";
BEGIN {
    $require_list

    use mro 'c3';
    our \@ISA;
    push \@ISA, $isa_list;
}
END
}

sub _compile_bless {
    my $self = shift;

    return 'bless \%args, $class';
}

sub _compile_new {
    my $self = shift;

    return sprintf <<'CODE', $self->_compile_bless, $self->_compile_defaults;
sub new {
    my $class = shift;
    my %%args  = @_;

    my $self = %s;

    %s

    return $self;
}
CODE
}

sub _compile_undef_default {
    my ( $self, $attribute ) = ( shift, @_ );

    return sprintf '$self->{%s} //= undef;', $attribute->name;
}

sub _compile_simple_default {
    my ( $self, $attribute ) = ( shift, @_ );

    return $self->_compile_undef_default($attribute) if !defined $attribute->default;
    return sprintf '$self->{%s} //= q[%s];', $attribute->name, $attribute->default;
}

sub _compile_coderef_default {
    my ( $self, $attribute ) = ( shift, @_ );

    my $var = $attribute->coderef_default_variable;

    return sprintf 'our %s; $self->{%s} //= %s->(\$self);',
      $var, $attribute->name, $var;
}

sub _compile_defaults {
    my $self = shift;

    my @simple_defaults = map { $self->_compile_simple_default($_) }
                              $self->_attributes_with_simple_defaults;
    my @coderef_defaults = map { $self->_compile_coderef_default($_) }
                               $self->_attributes_with_coderef_defaults;

    return join "\n", @simple_defaults, @coderef_defaults;
}

sub _attributes_with_defaults {
    my $self = shift;

    return grep { $_->has_default } values %{$self->all_attributes};
}

sub _attributes_with_simple_defaults {
    my $self = shift;

    return grep { $_->has_simple_default } values %{$self->all_attributes};
}

sub _attributes_with_coderef_defaults {
    my $self = shift;

    return grep { $_->has_coderef_default } values %{$self->all_attributes};
}

sub _attributes_with_dataref_defaults {
    my $self = shift;

    return grep { $_->has_dataref_default } values %{$self->all_attributes};
}

sub _compile_attributes {
    my $self = shift;

    my $code = '';
    for my $attribute (values %{$self->all_attributes}) {
        $code .= $attribute->compile;
    }

    return $code;
}

1;
