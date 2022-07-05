package Test::RoleTinyOtherRole;
use Role::Tiny;

requires 'boop';

sub quux { "QUUX" }
around quuux => sub { "QUUUX" };

1;
