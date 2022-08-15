use Test2::V0
	-target => 'MooseInteg::ChildClass';

{
	package OtherClass;
	sub quux { 'quuux' }
}

for my $class ( 'MooseInteg::BaseClass', 'MooseInteg::ChildClass' ) {
	my $role = 'MooseInteg::BaseClassRole';
	ok( $class->does( $role ), "$class does $role" );
	ok( $class->DOES( $role ), "$class DOES $role" );
}

my $obj = $CLASS->new( foo => 42, bar => bless( [], 'OtherClass' ), baz => {} );

ok( $obj->isa( 'MooseInteg::ChildClass' ), '$obj isa MooseInteg::ChildClass' );
ok( $obj->isa( 'MooseInteg::BaseClass' ), '$obj isa MooseInteg::BaseClass' );
ok( $obj->does( 'MooseInteg::SomeRole' ), '$obj does MooseInteg::SomeRole' );
ok( $obj->DOES( 'MooseInteg::SomeRole' ), '$obj DOES MooseInteg::SomeRole' );
ok( $obj->does( 'MooseInteg::BaseClassRole' ), '$obj does MooseInteg::BaseClassRole' );
ok( $obj->DOES( 'MooseInteg::BaseClassRole' ), '$obj DOES MooseInteg::BaseClassRole' );

is( $obj->foo, 42, '$obj->foo' );
is( $obj->bar, object {}, '$obj->bar' );
is( $obj->baz, {}, '$obj->baz' );

is( $obj->quux, 'quuux', '$obj->quux' );

done_testing;
