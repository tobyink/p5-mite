use 5.010001;
use strict;
use warnings;

package Mite::Source;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.013000';

has file =>
  is            => ro,
  isa           => Path,
  coerce        => true,
  required      => true;

has classes =>
  is            => ro,
  isa           => HashRef[MiteClass],
  default       => sub { {} };

has class_order =>
  is            => ro,
  isa           => ArrayRef[NonEmptyStr],
  default       => sub { [] };

has compiled =>
  is            => ro,
  isa           => MiteCompiled,
  lazy          => true,
  default       => sub {
      my $self = shift;
      return Mite::Compiled->new( source => $self );
  };

has project =>
  is            => rw,
  isa           => MiteProject,
  # avoid a circular dep with Mite::Project
  weak_ref      => true;

use Mite::Compiled;
use Mite::Class;

sub has_class {
    my ( $self, $name ) = ( shift, @_ );

    return defined $self->classes->{$name};
}

sub compile {
    my $self = shift;

    return $self->compiled->compile();
}

# Add an existing class instance to this source
sub add_classes {
    my ( $self, @classes ) = ( shift, @_ );

    for my $class (@classes) {
        $class->source($self);

        next if $self->classes->{$class->name};
        $self->classes->{$class->name} = $class;
        push @{ $self->class_order }, $class->name;
    }

    return;
}

# Create or reuse a class instance for this source give a name
sub class_for {
    my ( $self, $name, $metaclass ) = ( shift, @_ );
    $metaclass ||= 'Mite::Class';

    if ( not $self->classes->{$name} ) {
        eval "require $metaclass";
        $self->classes->{$name} = $metaclass->new(
            name    => $name,
            source  => $self,
        );
        push @{ $self->class_order }, $name;
    }

    return $self->classes->{$name};
}

sub _compile_mop {
    my ( $self, $name ) = @_;

    my $joined = join "\n",
        map { $self->classes->{$_}->_compile_mop }
        @{ $self->class_order };

    while ( $joined =~ /\n\n/ ) {
        $joined =~ s/\n\n/\n/g;
    }

    return sprintf <<'CODE', B::perlstring( "$name" ), $joined;
require %s;

%s
CODE
}

1;
