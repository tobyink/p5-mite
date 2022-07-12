#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "DEMOLISH" => sub {
    mite_load <<'CODE';
package PPP;
use Mite::Shim;
sub DEMOLISH {
    push @PPP::LOG, __PACKAGE__;
}

package CCC;
use Mite::Shim;
extends 'PPP';
sub DEMOLISH {
    push @PPP::LOG, __PACKAGE__;
}
1;
CODE

    no warnings 'once';

    my $o = CCC->new;
    is(
        \@PPP::LOG,
        [],
        'nothing demolished',
    );

    undef $o;
    is(
        \@PPP::LOG,
        [ 'CCC', 'PPP' ],
        'demolish worked',
    );
};

done_testing;
