use 5.010001;
use strict;
use warnings;

package Mite::Role::Tiny;
use Mite::Miteception -all;
extends qw(Mite::Role);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.009003';

sub inhale {
    my ( $class, $rolename, %args ) = @_;

    return $class->new(
        %args,
        name => $rolename,
        attributes => {},
        roles => [],
        required_methods => ( $Role::Tiny::INFO{$rolename}{requires} ||= [] ),
    );
}

sub methods_to_export {
    my $self = shift;

    my $rt_methods = 'Role::Tiny'->_concrete_methods_of( $self->name );
    my %mr_methods = map {
        $_ => sprintf '%s::%s', $self->name, $_;
    } keys %$rt_methods;

    return \%mr_methods;
}

1;
