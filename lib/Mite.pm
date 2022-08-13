use 5.010001;
use strict;
use warnings;

package Mite;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.010004';

1;

__END__

=pod

=head1 NAME

Mite - Moose-like OO, fast to load, with zero dependencies.

=head1 SYNOPSIS

Start a project:

    $ mite init Foo

Write a class (F<lib/Foo.pm>):

    package Foo;
    
    use Foo::Mite;
    
    has attribute => (
        is      => 'rw',
    );
    
    has another_attribute => (
        is      => 'ro',
        default => 'Hello world',
    );
    
    1;

Write another class (F<lib/Foo/Bar.pm>):

    package Foo::Bar;
    
    use Foo::Mite;
    extends 'Foo';
    
    sub my_method {
        my $class = shift;
        print $class->new->another_attribute, "\n";
    }
    
    1;

Compile your project:

    $ mite compile

Use your project:

    $ perl -Ilib -MFoo::Bar -E'Foo::Bar->my_method'

=head1 DESCRIPTION

Mite provides a subset of Moose features with very fast startup time
and zero dependencies.

L<Moose> and L<Moo> are great... unless you can't have any dependencies
or compile-time is critical.

Mite provides Moose-like functionality, but it does all the work
during development.  New source code is written which contains the OO
code.  Your project does not have to depend on Mite.  Nor does your
project have to spend time during startup to build OO features.

Mite is for a very narrow set of use cases.  Unless you specifically
need ultra-fast startup time or zero dependencies, use L<Moose> or
L<Moo>.

=head1 OPTIMIZATIONS

Mite writes pure Perl code and your module will run with no
dependencies.  It will also write code to use other, faster modules to
do the same job, if available.

These optimizations can be turned off by setting the C<PERL_ONLY>
environment variable true.

You may wish to add these as recommended dependencies.

=head2 Class::XSAccessor

Mite will use L<Class::XSAccessor> for accessors if available.  They
are significantly faster than those written in Perl.

=head1 WHY IS THIS

This module exists for a very special set of use cases.  Authors of
toolchain modules (Test::More, ExtUtils::MakeMaker, File::Spec,
etc...) who cannot easily depend on other CPAN modules.  It would
cause a circular dependency and add instability to CPAN.  These
authors are frustrated at not being able to use most of the advances
in Perl present on CPAN, such as Moose.

To add to their burden, by being used by almost everyone, toolchain
modules limit how fast modules can load.  So they have to compile very
fast.  They do not have the luxury of creating attributes and
including roles at compile time.  It must be baked in.

Use Mite if your project cannot have non-core dependencies or needs to
load very quickly.

=head1 BUGS

Please report any bugs to L<https://github.com/tobyink/p5-mite/issues>.

=head1 SEE ALSO

L<Mite::Manual::Workflow> - how to develop with Mite.

L<Mite::Manual::Keywords> - functions exported by Mite.

L<Mite::Manual::Attributes> - options for defining attributes with Mite.

L<Mite::Manual::Features> - other features provided by Mite.

L<Mite::Manual::MOP> - integration with the Moose Meta-Object Protocol.

L<Mite::Manual::Missing> - major Moose features not supported by Mite.

L<Mite::Manual::Benchmarking> - comparing Mite with Moose, Moo, and Mouse.

L<https://metacpan.org/dist/Acme-Mitey-Cards> - demo project.

L<Moose> is the complete Perl 5 OO module which this is all based on.

L<Moo> is a lighter-weight Moose-compatible module with fewer dependencies.

L<Type::Library::Compiler> allows you to create a zero-dependency compiled
version of your type constraint library, which can be used by Mite.


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
