#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "method modifiers" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
our @LOG;
sub xyz {
    push @LOG, 'METHOD';
    return $_[1];
}
around xyz => sub {
    my ( $orig, $self, @args ) = @_;
    push @LOG, 'AROUND1';
    my $r = $self->$orig( @args );
    push @LOG, 'AROUND2';
    return uc $r;
};
before xyz => sub {
    push @LOG, 'BEFORE';
};
after xyz => sub {
    push @LOG, 'AFTER';
};
1;
CODE

    my $o = MyTest->new;
    is $o->xyz( 'yes' ), 'YES';
    is(
        \@MyTest::LOG,
        [ 'BEFORE', 'AROUND1', 'METHOD', 'AROUND2', 'AFTER' ],
    ) or diag explain( \@MyTest::LOG );
};

done_testing;
