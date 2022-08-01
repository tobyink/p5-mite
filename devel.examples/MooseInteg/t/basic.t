use Test2::V0
	-target => 'MooseInteg::ChildClass';

{
	package OtherClass;
	sub quux { 'quuux' }
}

my $obj = $CLASS->new( foo => 42, bar => bless( [], 'OtherClass' ), baz => {} );

ok( $obj->isa( 'MooseInteg::ChildClass' ) );
ok( $obj->isa( 'MooseInteg::BaseClass' ) );
ok( $obj->does( 'MooseInteg::SomeRole' ) );
ok( $obj->DOES( 'MooseInteg::SomeRole' ) );

is( $obj->foo, 42 );
is( $obj->bar, object {} );
is( $obj->baz, {} );

is( $obj->quux, 'quuux' );

done_testing;
