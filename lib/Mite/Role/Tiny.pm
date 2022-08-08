use 5.010001;
use strict;
use warnings;

package Mite::Role::Tiny;
use Mite::Miteception -all;
extends qw(Mite::Role);

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.009001';

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

__END__

=pod

=head1 NAME

Mite::Role::Tiny - a role within a project, but using Role::Tiny

=head1 DESCRIPTION

NO USER SERVICABLE PARTS INSIDE.  This is a private class.

=head1 BUGS

Please report any bugs to L<https://github.com/tobyink/p5-mite/issues>.

=head1 AUTHOR

Michael G Schwern E<lt>mschwern@cpan.orgE<gt>.

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011-2014 by Michael G Schwern.

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

=cut
