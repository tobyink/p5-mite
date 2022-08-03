#!/usr/bin/perl

use lib 't/lib';

use Test::Mite;

tests "eager default doesn't trigger" => sub {
    mite_load <<'CODE';
package MyTest;
use Mite::Shim;
has attr =>
  is => 'rw',
  trigger => 1,
  default => 'default';
has log =>
  is => 'ro',
  default => sub { [] },
  lazy => 1;
sub _trigger_attr {
  my $self = shift;
  push @{ $self->log }, [ @_ ];
}
1;
CODE

    {
        my $o = MyTest->new( attr => 'constructor' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'constructor' ],
                [ 'accessor1', 'constructor' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, explicit attribute value',
        );
    }

    {
        my $o = MyTest->new();
        is( $o->{attr}, 'default' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'accessor1', 'default' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, default attribute value',
        );
    }
};

tests "lazy default doesn't trigger" => sub {
    mite_load <<'CODE';
package MyTest2;
use Mite::Shim;
has attr =>
  is => 'rw',
  trigger => 1,
  lazy => 1,
  default => 'default';
has log =>
  is => 'ro',
  default => sub { [] },
  lazy => 1;
sub _trigger_attr {
  my $self = shift;
  push @{ $self->log }, [ @_ ];
}
1;
CODE

    {
        my $o = MyTest2->new( attr => 'constructor' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'constructor' ],
                [ 'accessor1', 'constructor' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, explicit attribute value',
        );
    }

    {
        my $o = MyTest2->new();
        ok( !exists $o->{attr} );
        is( $o->attr, 'default' );
        is( $o->{attr}, 'default' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'accessor1', 'default' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, default attribute value',
        );
    }
};

tests "eager default does trigger" => sub {
    mite_load <<'CODE';
package MyTest3;
use Mite::Shim;
has attr =>
  is => 'rw',
  trigger => 1,
  default => 'default',
  default_does_trigger => 1;
has log =>
  is => 'ro',
  default => sub { [] },
  lazy => 1;
sub _trigger_attr {
  my $self = shift;
  push @{ $self->log }, [ @_ ];
}
1;
CODE

    {
        my $o = MyTest3->new( attr => 'constructor' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'constructor' ],
                [ 'accessor1', 'constructor' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, explicit attribute value',
        );
    }

    {
        my $o = MyTest3->new();
        is( $o->{attr}, 'default' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'default' ],
                [ 'accessor1', 'default' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, default attribute value',
        );
    }
};

tests "lazy default does trigger" => sub {
    mite_load <<'CODE';
package MyTest4;
use Mite::Shim;
has attr =>
  is => 'rw',
  trigger => 1,
  lazy => 1,
  default => 'default',
  default_does_trigger => 1;
has log =>
  is => 'ro',
  default => sub { [] },
  lazy => 1;
sub _trigger_attr {
  my $self = shift;
  push @{ $self->log }, [ @_ ];
}
1;
CODE

    {
        my $o = MyTest4->new( attr => 'constructor' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'constructor' ],
                [ 'accessor1', 'constructor' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, explicit attribute value',
        );
    }

    {
        my $o = MyTest4->new();
        ok( !exists $o->{attr} );
        is( $o->attr, 'default' );
        is( $o->{attr}, 'default' );
        $o->attr( 'accessor1' );
        $o->attr( 'accessor2' );

        is(
            $o->log,
            [
                [ 'default' ],
                [ 'accessor1', 'default' ],
                [ 'accessor2', 'accessor1' ],
            ],
            'expected results, default attribute value',
        );
    }
};

done_testing;
