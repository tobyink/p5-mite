use Test2::V0
	-target => 'MooseInteg::ChildClass';

my $obj = $CLASS->new;
is( $obj->number( 1, 2, 1 ), 42 );

done_testing;
