#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "alias" => sub {
    mite_load <<'CODE';
package MyPerson;
use Mite::Shim;
has first_name =>
    is => 'rw',
    alias => 'given_name',
    required => 1;
has last_name =>
    is => 'rwp',
    alias => [ 'family_name', 'surname' ],
    required => 1;
has age =>
    is => 'ro',
    alias => [];
has height =>
    is => 'ro',
    alias => undef;
1;
CODE

    my $alice = MyPerson->new( given_name => 'Alice', surname => 'Jones' );
    is $alice->first_name, 'Alice';
    is $alice->given_name, 'Alice';
    is $alice->last_name, 'Jones';
    is $alice->family_name, 'Jones';
    is $alice->surname, 'Jones';

    $alice->given_name( 'Ali' );
    is $alice->first_name, 'Ali';

    {
        local $@;
        eval { $alice->last_name( 'Smith' ) };
        my $e = $@;
        isnt $e, undef;
    }
};

done_testing;
