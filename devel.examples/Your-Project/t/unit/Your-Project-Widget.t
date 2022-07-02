# t/unit/Your-Project-Widget.t
use Test2::V0
	-target => 'Your::Project::Widget';

can_ok( $CLASS, 'new' );

my $object = $CLASS->new( name => 'Quux' );
isa_ok( $object, $CLASS );

subtest 'Method `name`' => sub {
	can_ok( $object, 'name' );
	is( $object->name, 'Quux', 'expected value' );
	
	my $exception = dies {
		$object->name( 'XYZ' );
	};
	isnt( $exception, undef, 'read-only attribute' );
};

subtest 'Method `upper_case_name`' => sub {
	can_ok( $object, 'upper_case_name' );
	is( $object->upper_case_name, 'QUUX', 'expected value' );
};

done_testing;
