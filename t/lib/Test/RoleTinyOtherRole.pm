package Test::RoleTinyOtherRole;
use Role::Tiny;

sub quux { "QUUX" }
around quuux => sub { "QUUUX" };

1;
