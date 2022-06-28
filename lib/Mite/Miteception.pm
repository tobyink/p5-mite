use 5.010001;
use strict;
use warnings;

package Mite::Miteception;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001001';

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

	no strict 'refs';
	*{ $caller .'::has' } = sub {
		 my $names = shift;
		 $names = [$names] unless ref $names;
		 my %args = @_;
		 for my $name ( @$names ) {
			 $name =~ s/^\+//;

			 my $default = $args{default};
			 if ( ref $default eq 'CODE' ) {
				  ${$caller .'::__'.$name.'_DEFAULT__'} = $default;
			 }

			 my $builder = $args{builder};
			 if ( ref $builder eq 'CODE' ) {
				  *{"$caller\::_build_$name"} = $builder;
			 }

			 my $trigger = $args{trigger};
			 if ( ref $trigger eq 'CODE' ) {
				  *{"$caller\::_trigger_$name"} = $trigger;
			 }
		 }

		 return;
	};

	# Inject blank Mite routines
	for my $name (qw( extends )) {
		 no strict 'refs';
		 *{ $caller .'::'. $name } = sub {};
	}
}

1;
