package Mite::App;

use feature ':5.10';
use strict;
use warnings;

use App::Cmd::Setup -app;

# Prevent .pm.mite files from getting found as plugins.
#
sub _plugins {
	my $self = shift;
	grep !/\.pm\.mite/, $self->SUPER::_plugins( @_ );
}

1;
