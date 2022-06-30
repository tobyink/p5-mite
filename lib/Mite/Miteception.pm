use 5.010001;
use strict;
use warnings;

package Mite::Miteception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001013';

my %constants;
BEGIN {
	%constants = (
		rw        => 'rw',
		rwp       => 'rwp',
		ro        => 'ro',
		true      => !!1,
		false     => !!0,
	);
}

use constant \%constants;

use Import::Into;
use Mite::Shim ();
use Carp ();
use Scalar::Util ();
use Types::Standard ();
use Types::Path::Tiny ();
use Type::Params ();
use namespace::autoclean ();
use feature ();

sub import {
	my ( $class, $arg ) = ( shift, @_ );
	for my $import ( $class->to_import( $arg ) ) {
		my ( $pkg, $args ) = @$import;
		$pkg->import::into( 1, @{ $args || [] } );
	}

	no strict 'refs';
	my $caller = caller;
	*{"$caller\::$_"} = \&{$_} for $class->constant_names;

	return if ( defined $arg and $arg eq '-Basic' );

	unshift @_, $class;
	goto \&load_mite_file;
}

sub constant_names {
	my $class = shift;
	return keys %constants;
}

sub to_import {
	my ( $class, $arg ) = ( shift, @_ );
	no warnings 'uninitialized';
	return (
		( $arg eq '-Basic' ? () : [ 'namespace::autoclean' ] ),
		[ 'Carp' => [
			qw( carp croak confess ),
		] ],
		[ 'Scalar::Util' => [
			qw( blessed ),
		] ],
		[ 'Types::Standard' => [
			qw( -types slurpy ),
		] ],
		[ 'Types::Path::Tiny' => [
			qw( -types ),
		] ],
		[ 'Type::Params' => [
			compile           => { -as => 'sig_pos'   },
			compile_named_oo  => { -as => 'sig_named' },
		] ],
		[ 'feature' => [
			':5.10',
		] ],
	);
}

# Stolen bits from Mite::Shim
sub load_mite_file {
	my $class = shift;

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

	'Mite::Shim'->_install_exports( $caller, $file );
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
