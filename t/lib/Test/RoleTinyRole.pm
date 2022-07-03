package Test::RoleTinyRole;
use Role::Tiny;
with 'Test::RoleTinyOtherRole';

sub foo { "FOO" }
sub bar { "BZZT" }
around baz => sub { "BAZ" };

1;
