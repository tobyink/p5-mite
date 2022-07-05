use strict;
use warnings;
use Test::More;

my $e = do {
	local $@;
	eval { require Bad::Example::Class2; };
	$@;
};

like $e, qr/Bad::Example::Role2 requires Bad::Example::Class2 to implement methods: missing/;

done_testing;
