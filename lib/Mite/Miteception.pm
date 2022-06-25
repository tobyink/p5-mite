package Mite::Miteception;
use v5.10;
use strict;
use warnings;

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
use Moo ();
use Carp ();
use Scalar::Util ();
use Types::Standard ();
use Types::Path::Tiny ();
use Type::Params ();
use namespace::autoclean ();
use feature ();

sub import {
	my $class  = shift;
	my $caller = caller;
	local $ENV{MITE_COMPILE} = 0;
	for my $import ( $class->to_import( @_ ) ) {
		my ( $pkg, $args ) = @$import;
		$pkg->import::into( $caller, @{ $args || [] } );
	}
	
	no strict 'refs';
	*{"$caller\::$_"} = \&{$_} for $class->constant_names;
}

sub constant_names {
	my $class = shift;
	return keys %constants;
}

sub to_import {
	my ( $class, $arg ) = ( shift, @_ );
	no warnings 'uninitialized';
	return (
		( $arg eq '-Basic' ? () : [ 'Moo' ] ),
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

1;
