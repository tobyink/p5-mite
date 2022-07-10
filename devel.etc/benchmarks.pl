#!/usr/bin/env perl

use v5.30;
use warnings;

use File::chdir;
use Path::Tiny qw( path );

my $MAX = 500;

for my $toolkit ( qw/ Moo Mouse Moose Mite / ) {

	my $project_dir = path( $toolkit =~ s/::/_/gr );
	$project_dir->child('lib/Local/Math/')->mkpath;

	if ( $toolkit eq 'Mite' ) {
		local $CWD = "$project_dir";
		system mite => qw( init Local );
	}

	my $load = '';
	for my $n ( 1 .. $MAX ) {
		$project_dir->child("lib/Local/Math/Add$n.pm")->spew(
			make_adder_class( $n, $toolkit )
		);
		$load .= "use Local::Math::Add$n;\n";
	}

	$project_dir->child('bin/')->mkpath;
	$project_dir->child('bin/run-test.pl')->spew(<<"TEST");
use strict;
use warnings;
use Time::HiRes qw(time);

my ( \$start, \$loaded, \$finished );

BEGIN {
	\$start = time();
}

$load;

BEGIN {
	\$loaded = time();
}

for my \$n ( 1 .. $MAX ) {
	my \$class  = "Local::Math::Add\$n";
	my \$object = \$class->new;
	\$object->do_sum( 0 ) == \$n or die;
}

\$finished = time();

printf( "Toolkit:   %s\n", "$toolkit" );
printf( "Load time: %0.4f\n", \$loaded - \$start );
printf( "Run time:  %0.4f\n", \$finished - \$loaded );
TEST

	if ( $toolkit eq 'Mite' ) {
		local $CWD = "$project_dir";
		system mite => qw( compile );
	}
}

sub make_adder_class {
	my ( $n, $toolkit ) = @_;

	my $module = ( $toolkit eq 'Mite'  ) ? 'Local::Mite' : $toolkit;
	my $end    = ( $toolkit eq 'Moose' ) ? '__PACKAGE__->meta->make_immutable; 1;' : '1;';
	return <<"MODULE";
package Local::Math::Add$n;

use $module;

has base => (
	is => 'ro',
	default => $n,
);

has number_to_add => (
	is => 'ro',
	lazy => 1,
	builder => '_build_number_to_add',
);

sub _build_number_to_add {
	my \$self = shift;
	return \$self->base;
}

sub do_sum {
	my \$self = shift;
	return \$_[0] + \$self->number_to_add;
}

$end
MODULE
}
