use 5.010001;
use strict;
use warnings;

package Mite::Miteception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.008000';

use Import::Into;
use Mite::Shim ();
use Mite::Types ();

sub import {
	'Mite::Types'->import::into( 1, qw( -types slurpy ) );

	if ( $ENV{MITE_COMPILE_SELF} ) {
		my $class = shift;
		my %arg = map { lc($_) => 1 } @_;
		my ( $caller, $file ) = caller;
		require Mite::Project;
		Mite::Project->default->inject_mite_functions(
			 package     => $caller,
			 file        => $ENV{MITE_COMPILE_SELF},
			 arg         => \%arg,
			 kind        => ( $arg{'-role'} ? 'role' : 'class' ),
			 shim        => 'Mite::Shim',
		);
	}
	else {
		goto \&load_mite_file;
	}
}

# Stolen bits from Mite::Shim
sub load_mite_file {
	my $class = shift;
	my %arg = map { lc($_) => 1 } @_;

	my ( $caller, $file ) = caller;
	my $mite_file = $file . ".mite.pm";

	if( !-e $mite_file ) {
		 require Carp;
		 Carp::croak("Compiled Mite file ($mite_file) for $file is missing");
	}

	{
		 local @INC = ('.', @INC);
		 require $mite_file;
	}

	'Mite::Shim'->_inject_mite_functions( $caller, $file, 'class', \%arg );
}

1;

__END__

=pod

=head1 NAME

Mite::Miteception - Mite within a Mite

=head1 DESCRIPTION

NO USER SERVICABLE PARTS INSIDE.  This is a private class.

=head1 BUGS

Please report any bugs to L<https://github.com/tobyink/p5-mite/issues>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut
