BEGIN {
  package Class::Diminutive;
  sub new {
    my $class = shift;
    my $args = $class->BUILDARGS(@_);
    my $no_build = delete $args->{__no_BUILD__};
    my $self = bless { %$args }, $class;
    $self->BUILDALL
      unless $no_build;
    return $self;
  }
  sub BUILDARGS {
    my $class = shift;
    my %args = @_ % 2 ? %{$_[0]} : @_;
    return \%args;
  }
  sub BUILDALL {
    my $self = shift;
    my $class = ref $self;
    my @builds =
      grep { defined }
      map {; no strict 'refs'; *{$_.'::BUILD'}{CODE} }
      @{mro::get_linear_isa($class)};
    for my $build (@builds) {
      $self->$build;
    }
  }
}

BEGIN {
  package TestClass1;
  our @ISA = ('Class::Diminutive');
  sub BUILD {
    $_[0]->{build_called}++;
  }
  sub BUILDARGS {
    my $class = shift;
    my $args = $class->SUPER::BUILDARGS(@_);
    $args->{no_build_used} = $args->{__no_BUILD__};
    return $args;
  }
}

1;