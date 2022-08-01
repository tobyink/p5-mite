use Test2::V0
	-target => 'MooseInteg::ChildClass';

my $obj = $CLASS->new( foo => 42, bar => [], baz => {} );

ok( $obj->isa( 'MooseInteg::ChildClass' ) );
ok( $obj->isa( 'MooseInteg::BaseClass' ) );
ok( $obj->does( 'MooseInteg::SomeRole' ) );

is( $obj->foo, 42 );
is( $obj->bar, [] );
is( $obj->baz, {} );

done_testing;
