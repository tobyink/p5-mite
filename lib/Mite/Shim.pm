use 5.008001;
use strict;
use warnings;

package Mite::Shim;

# NOTE: Since the intention is to ship this file with a project, this file
# cannot have any non-core dependencies.

use strict;
use warnings;

if ( $] < 5.009005 ) {
    require MRO::Compat;
}
else {
    require mro;
}

defined ${^GLOBAL_PHASE}
or eval { require Devel::GlobalDestruction; 1 }
or do {
    warn "WARNING: Devel::GlobalDestruction recommended!\n";
    *Devel::GlobalDestruction::in_global_destruction = sub { undef; };
};

sub _is_compiling {
    return $ENV{MITE_COMPILE} ? 1 : 0;
}

sub _make_has {
    my ( $class, $caller, $file, $kind ) = @_;

    return sub {
        my $names = shift;
        $names = [$names] unless ref $names;
        my %args = @_;
        for my $name ( @$names ) {
           $name =~ s/^\+//;

           my $default = $args{default};
           if ( ref $default eq 'CODE' ) {
               no strict 'refs';
               ${$caller .'::__'.$name.'_DEFAULT__'} = $default;
           }

           my $builder = $args{builder};
           if ( ref $builder eq 'CODE' ) {
               no strict 'refs';
               *{"$caller\::_build_$name"} = $builder;
           }

           my $trigger = $args{trigger};
           if ( ref $trigger eq 'CODE' ) {
               no strict 'refs';
               *{"$caller\::_trigger_$name"} = $trigger;
           }
        }

        return;
    };
}

sub _make_with {
    my ( $class, $caller, $file, $kind ) = @_;

    return sub {
        while ( @_ ) {
            my $role = shift;
            my $args = ref($_[0]) ? shift : undef;
            if ( $INC{'Role/Tiny.pm'} and 'Role::Tiny'->is_role( $role ) ) {
                $class->_finalize_application_roletiny( $role, $caller, $args );
            }
            else {
                $role->__FINALIZE_APPLICATION__( $caller, $args );
            }
        }
        return;
    };
}

{
    my ( $cb_before, $cb_after );
    sub _finalize_application_roletiny {
        my ( $class, $role, $caller, $args ) = @_;

        if ( $INC{'Role/Hooks.pm'} ) {
            $cb_before ||= \%Role::Hooks::CALLBACKS_BEFORE_APPLY;
            $cb_after  ||= \%Role::Hooks::CALLBACKS_AFTER_APPLY;
        }
        if ( $cb_before ) {
            $_->( $role, $caller ) for @{ $cb_before->{$role} || [] };
        }

        my $info = $Role::Tiny::INFO{$role};
        for ( @{ $info->{modifiers} || [] } ) {
            my @args = @$_;
            my $kind = shift @args;
            $class->$kind( $caller, @args );
        }

        if ( $cb_after ) {
            $_->( $role, $caller ) for @{ $cb_after->{$role} || [] };
        }

        return;
    }
}

sub import {
    my ( $class, $kind ) = @_;
    my ( $caller, $file ) = caller;

    # Turn on warnings and strict in the caller
    warnings->import;
    strict->import;

    $kind ||= 'class';
    $kind = ( $kind =~ /role/i ) ? 'role' : 'class';

    if( _is_compiling() ) {
        require Mite::Project;
        my $method = "inject_mite_$kind\_functions";
        Mite::Project->default->$method(
            package     => $caller,
            file        => $file,
        );
    }
    else {
        # Work around Test::Compile's tendency to 'use' modules.
        # Mite.pm won't stand for that.
        return if $ENV{TEST_COMPILE};

        # Changes to this filename must be coordinated with Mite::Compiled
        my $mite_file = $file . ".mite.pm";
        if( !-e $mite_file ) {
            require Carp;
            Carp::croak("Compiled Mite file ($mite_file) for $file is missing");
        }

        {
            local @INC = ('.', @INC);
            require $mite_file;
        }

        my $method = "_inject_mite_$kind\_functions";
        $class->$method( $caller, $file );
    }
}

my $parse_mm_args = sub {
    my $coderef = pop;
    my $names   = [ map { ref($_) ? @$_ : $_ } @_ ];
    ( $names, $coderef );
};

{
    my $get_orig = sub {
        my ( $caller, $name ) = @_;

        my $orig = $caller->can($name);
        return $orig if $orig;

        require Carp;
        Carp::croak( "Cannot modify method $name in $caller: no such method" );
    };

    sub before {
        my ( $me, $caller ) = ( shift, shift );
        my ( $names, $coderef ) = &$parse_mm_args;
        for my $name ( @$names ) {
            my $orig = $get_orig->( $caller, $name );
            local $@;
            eval <<"BEFORE" or die $@;
                package $caller;
                no warnings 'redefine';
                sub $name {
                    \$coderef->( \@_ );
                    \$orig->( \@_ );
                }
                1;
BEFORE
        }
        return;
    }

    sub after {
        my ( $me, $caller ) = ( shift, shift );
        my ( $names, $coderef ) = &$parse_mm_args;
        for my $name ( @$names ) {
            my $orig = $get_orig->( $caller, $name );
            local $@;
            eval <<"AFTER" or die $@;
                package $caller;
                no warnings 'redefine';
                sub $name {
                    my \@r;
                    if ( wantarray ) {
                        \@r = \$orig->( \@_ );
                    }
                    elsif ( defined wantarray ) {
                        \@r = scalar \$orig->( \@_ );
                    }
                    else {
                        \$orig->( \@_ );
                        1;
                    }
                    \$coderef->( \@_ );
                    wantarray ? \@r : \$r[0];
                }
                1;
AFTER
        }
        return;
    }

    sub around {
        my ( $me, $caller ) = ( shift, shift );
        my ( $names, $coderef ) = &$parse_mm_args;
        for my $name ( @$names ) {
            my $orig = $get_orig->( $caller, $name );
            local $@;
            eval <<"AROUND" or die $@;
                package $caller;
                no warnings 'redefine';
                sub $name {
                    \$coderef->( \$orig, \@_ );
                }
                1;
AROUND
        }
        return;
    }
}


sub _inject_mite_class_functions {
    my ( $class, $caller, $file ) = ( shift, @_ );

    no strict 'refs';
    *{ $caller .'::has' } = $class->_make_has( $caller, $file, 'class' );
    *{ $caller .'::with' } = $class->_make_with( $caller, $file, 'class' );
    *{ $caller .'::extends'} = sub {};

    for my $mm ( qw/ before after around / ) {
        *{"$caller\::$mm"} = sub {
            $class->$mm( $caller, @_ );
            return;
        };
    }
}

sub _inject_mite_role_functions {
    my ( $class, $caller, $file ) = ( shift, @_ );

    no strict 'refs';
    *{ $caller .'::has' } = $class->_make_has( $caller, $file, 'role' );
    *{ $caller .'::with' } = $class->_make_with( $caller, $file, 'role' );

    my $MM = \@{"$caller\::METHOD_MODIFIERS"};
    for my $modifier ( qw/ before after around / ) {
        *{ $caller .'::'. $modifier } = sub {
            my ( $names, $coderef ) = &$parse_mm_args;
            push @$MM, [ $modifier, $names, $coderef ];
        };
    }
}

1;

__END__

=pod

=head1 NAME

Mite::Shim - shim to load .mite.pm files

=head1 DESCRIPTION

This is a copy of L<Mite::Shim>.

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
