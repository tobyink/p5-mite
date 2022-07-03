package Test::RoleTinyYetAnotherRole;
use Role::Tiny;
use Role::Hooks;

our @LOG;

'Role::Hooks'->after_apply( __PACKAGE__, sub {
    push @LOG, [ @_ ];
} );

1;
