#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "FOREIGNBUILDARGS" => sub {
    mite_load <<'CODE';
package My::Deparse;
use Mite::Shim;
extends 'B::Deparse';
sub FOREIGNBUILDARGS {
    my $class = shift;
    my %args = ( @_ == 1 ) ? %{$_[0]} : @_;
    $args{use_dumper} ? ( '-d' ) : ();
}

1;
CODE

    {
        my $o = My::Deparse->new( use_dumper => 1 );
        is $o->{'use_dumper'}, 1;
    }

    {
        my $o = My::Deparse->new( use_dumper => '' );
        is $o->{'use_dumper'}, 0;
    }
};

done_testing;
