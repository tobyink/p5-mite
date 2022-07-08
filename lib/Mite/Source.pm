use 5.010001;
use strict;
use warnings;

package Mite::Source;
use Mite::Miteception -all;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.005003';

has file =>
  is            => ro,
  isa           => Path->no_coercions->plus_coercions(Str, 'Path::Tiny::path($_)'),,
  coerce        => true,
  required      => true;

has classes =>
  is            => ro,
  isa           => HashRef[InstanceOf['Mite::Class']],
  default       => sub { {} };

has compiled =>
  is            => ro,
  isa           => InstanceOf['Mite::Compiled'],
  lazy          => true,
  default       => sub {
      my $self = shift;
      return Mite::Compiled->new( source => $self );
  };

has project =>
  is            => rw,
  isa           => InstanceOf['Mite::Project'],
  # avoid a circular dep with Mite::Project
  weak_ref      => true;

##-

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
        $self->classes->{$class->name} = $class;
        $class->source($self);
    }

    return;
}

# Create or reuse a class instance for this source give a name
sub class_for {
    my ( $self, $name, $metaclass ) = ( shift, @_ );
    $metaclass ||= 'Mite::Class';

    return $self->classes->{$name} ||= $metaclass->new(
        name    => $name,
        source  => $self,
    );
}

1;

__END__

=pod

=head1 NAME

Mite::Source - Representing the human written .pm file.

=head1 SYNOPSIS

    use Mite::Source;
    my $source = Mite::Source->new( file => $pm_filename );

=head1 DESCRIPTION

NO USER SERVICABLE PARTS INSIDE.  This is a private class.

Represents a .pm file, written by a human, which uses Mite.

It is responsible for information about the source file.

* The Mite classes contained in the source.
* The compiled Mite file associated with it.

It delegates most work to other classes.

This object is necessary because there can be multiple Mite classes in
one source file.

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
