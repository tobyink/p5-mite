#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "selective import" => sub {
    mite_load <<'CODE';
package MyTest1;
use Mite::Shim qw( -bool -is -unclean );
package MyTest2;
use Mite::Shim qw( !has !before !after !around -unclean );
package MyTest3;
use Mite::Shim qw( !-defaults has -unclean );
1;
CODE

    for my $func ( qw/ has before after around true false rw ro rwp / ) {
        ok MyTest1->can( $func ), "MyTest1 can $func";
        ok !MyTest2->can( $func ), "MyTest2 can't $func";
        if ( $func eq 'has' ) {
            ok MyTest3->can( $func ), "MyTest3 can $func";
        }
        else {
            ok !MyTest3->can( $func ), "MyTest3 can't $func";
        }
    }

    ok MyTest1->can( 'extends' );
    ok MyTest2->can( 'extends' );
    ok MyTest1->can( 'with' );
    ok MyTest2->can( 'with' );

    is MyTest1::true(), !!1;
    is MyTest1::false(), !!0;
    is MyTest1::rw(), 'rw';
    is MyTest1::ro(), 'ro';
    is MyTest1::rwp(), 'rwp';
};

tests "-all" => sub {
    mite_load <<'CODE';
package MyTestAll;
use Mite::Shim qw( -all -unclean );
1;
CODE

    for my $func ( qw/ has extends with before after around true false rw ro rwp bare lazy carp croak confess blessed guard STRICT / ) {
        ok MyTestAll->can( $func ), "MyTestAll can $func";
    }
    
    ok !MyTestAll->can( 'requires' ), "MyTestAll can't with";
};

done_testing;
