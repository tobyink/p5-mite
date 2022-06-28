use 5.010001;
use strict;
use warnings;

package Mite::App;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001001';

use App::Cmd::Setup -app;

# Prevent .pm.mite files from getting found as plugins.
#
sub _plugins {
	my $self = shift;
	grep !/\.pm\.mite/, $self->SUPER::_plugins( @_ );
}

1;
