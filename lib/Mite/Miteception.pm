use 5.010001;
use strict;
use warnings;

package Mite::Miteception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.013000';

use Import::Into;
use Mite::Shim ();
use Mite::Types ();

sub import {
	'Mite::Types'->import::into( 1, qw( -types slurpy ) );

	if ( Mite::Shim::_is_compiling() and defined $Mite::REAL_FILENAME ) {
		my $class = shift;
		my %arg = map { lc($_) => 1 } @_;
		my ( $caller, $file ) = caller;
		require Mite::Project;
		Mite::Project->default->inject_mite_functions(
			package     => $caller,
			file        => $Mite::REAL_FILENAME,
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
	my %arg = map { lc $_ => 1 } @_;

	my ( $caller, $file ) = caller;

	require File::Spec;
	my $orig = $file;
	for my $base ( @INC ) {
		$base eq substr $file, 0, length $base
		and -f File::Spec->catfile( $base, substr $file, 1 + length $base )
		and $orig = File::Spec->abs2rel( $file, $base )
		and last;
	}

	my $mite_file = $orig . ".mite.pm";
	local $@;
	if ( not eval { require $mite_file; 1 } ) {
		my $e = $@;
		require Carp;
		Carp::croak("Compiled Mite file ($mite_file) for $file is missing or an error occurred loading it: $e");
	}
}

1;
