# t/unit/Your-Project-SomeClass.t
use Test2::V0
	-target => 'Your::Project::SomeClass';

can_ok( $CLASS, 'new' );

my $object = $CLASS->new();
isa_ok( $object, $CLASS );

ok( $object->does( $CLASS ) );

ok( $object->does( 'Your::Project::SomeRole' ) );

subtest 'Method `foo`' => sub {
	can_ok( $object, 'foo' );
	is( $object->foo, 'FOO' );
};

done_testing;
