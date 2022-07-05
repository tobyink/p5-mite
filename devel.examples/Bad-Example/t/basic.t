use strict;
use warnings;
use Test::More;

my $e = do {
	local $@;
	eval { require Bad::Example::Class; };
	$@;
};

like $e, qr/Bad::Example::Role requires Bad::Example::Class to implement methods: missing/;

done_testing;
