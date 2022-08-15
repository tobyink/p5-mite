package MooseInteg::MOP;

use Moose ();
use Moose::Util ();
use Moose::Util::MetaRole ();
use Moose::Util::TypeConstraints ();
use constant { true => !!1, false => !!0 };

my $META_CLASS = do {
    package MooseInteg::MOP::Meta::Class;
    use Moose;
    extends 'Moose::Meta::Class';
    around _immutable_options => sub {
        my ( $next, $self, @args ) = ( shift, shift, @_ );
        return $self->$next( replace_constructor => 1, @args );
    };
    __PACKAGE__->meta->make_immutable;

    __PACKAGE__;
};

my $META_ROLE = do {
    package MooseInteg::MOP::Meta::Role;
    use Moose;
    extends 'Moose::Meta::Role';
    my $built_ins = qr/\A( DOES | does | __META__ | __FINALIZE_APPLICATION__ |
        CREATE_CLASS | APPLY_TO )\z/x;
    around get_method => sub {
        my ( $next, $self, $method_name ) = ( shift, shift, @_ );
        return if $method_name =~ $built_ins;
        return $self->$next( @_ );
    };
    around get_method_list => sub {
        my ( $next, $self ) = ( shift, shift );
        return grep !/$built_ins/, $self->$next( @_ );
    };
    around _get_local_methods => sub {
        my ( $next, $self ) = ( shift, shift );
        my %map = %{ $self->_full_method_map };
        return map $map{$_}, $self->get_method_list;
    };
    __PACKAGE__->meta->make_immutable;

    __PACKAGE__;
};

require "MooseInteg/BaseClass.pm";

{
    my $PACKAGE = $META_CLASS->initialize( "MooseInteg::BaseClass", package => "MooseInteg::BaseClass" );
    my %ATTR;
    $ATTR{"xyzzy"} = Moose::Meta::Attribute->new( "xyzzy",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/MooseInteg/BaseClassRole.pm", line => "5", package => "MooseInteg::BaseClassRole", toolkit => "Mite", type => "role" },
        is => "rw",
        weak_ref => false,
        init_arg => "xyzzy",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Int() },
        accessor => "xyzzy",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"xyzzy"},
            name => "xyzzy",
            body => \&MooseInteg::BaseClass::xyzzy,
            package_name => "MooseInteg::BaseClass",
            definition_context => { context => "has declaration", description => "accessor MooseInteg::BaseClass::xyzzy", file => "lib/MooseInteg/BaseClassRole.pm", line => "5", package => "MooseInteg::BaseClassRole", toolkit => "Mite", type => "role" },
        );
        $ATTR{"xyzzy"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
        no warnings 'redefine';
        local *Moose::Meta::Attribute::install_accessors = sub {};
        $PACKAGE->add_attribute( $ATTR{"xyzzy"} );
    };
    $ATTR{"foo"} = Moose::Meta::Attribute->new( "foo",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/MooseInteg/BaseClass.pm", line => "6", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
        is => "rw",
        weak_ref => false,
        init_arg => "foo",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Int() },
        accessor => "foo",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"foo"},
            name => "foo",
            body => \&MooseInteg::BaseClass::foo,
            package_name => "MooseInteg::BaseClass",
            definition_context => { context => "has declaration", description => "accessor MooseInteg::BaseClass::foo", file => "lib/MooseInteg/BaseClass.pm", line => "6", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
        );
        $ATTR{"foo"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
        no warnings 'redefine';
        local *Moose::Meta::Attribute::install_accessors = sub {};
        $PACKAGE->add_attribute( $ATTR{"foo"} );
    };
    $ATTR{"hashy"} = Moose::Meta::Attribute->new( "hashy",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/MooseInteg/BaseClass.pm", line => "11", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
        is => "ro",
        weak_ref => false,
        init_arg => "hashy",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::HashRef()->parameterize( Types::Standard::Int() ) },
        reader => "hashy",
        default => sub { {} },
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"hashy"},
            name => "hashy",
            body => \&MooseInteg::BaseClass::hashy,
            package_name => "MooseInteg::BaseClass",
            definition_context => { context => "has declaration", description => "reader MooseInteg::BaseClass::hashy", file => "lib/MooseInteg/BaseClass.pm", line => "11", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
        );
        $ATTR{"hashy"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $DELEGATION = Moose::Meta::Method->_new(
            name => "hashy_set",
            body => \&MooseInteg::BaseClass::hashy_set,
            package_name => "MooseInteg::BaseClass",
        );
        $ATTR{"hashy"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    do {
        no warnings 'redefine';
        local *Moose::Meta::Attribute::install_accessors = sub {};
        $PACKAGE->add_attribute( $ATTR{"hashy"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&MooseInteg::BaseClass::meta,
            package_name => "MooseInteg::BaseClass",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "MooseInteg::BaseClass" );
}

require "MooseInteg/BaseClassRole.pm";

{
    my $PACKAGE = $META_ROLE->initialize( "MooseInteg::BaseClassRole", package => "MooseInteg::BaseClassRole" );
    my %ATTR;
    $ATTR{"xyzzy"} = Moose::Meta::Role::Attribute->new( "xyzzy",
        __hack_no_process_options => true,
        associated_role => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/MooseInteg/BaseClassRole.pm", line => "5", package => "MooseInteg::BaseClassRole", toolkit => "Mite", type => "role" },
        is => "rw",
        weak_ref => false,
        init_arg => "xyzzy",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Int() },
        accessor => "xyzzy",
    );
    delete $ATTR{"xyzzy"}{original_options}{$_} for qw( associated_role );
    do {
        no warnings 'redefine';
        local *Moose::Meta::Attribute::install_accessors = sub {};
        $PACKAGE->add_attribute( $ATTR{"xyzzy"} );
    };
    for ( @MooseInteg::BaseClassRole::METHOD_MODIFIERS ) {
        my ( $type, $names, $code ) = @$_;
        $PACKAGE->${\"add_$type\_method_modifier"}( $_, $code ) for @$names;
    }
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&MooseInteg::BaseClassRole::meta,
            package_name => "MooseInteg::BaseClassRole",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_does_type_constraint( "MooseInteg::BaseClassRole" );
}

require "MooseInteg/SomeRole.pm";

{
    my $PACKAGE = $META_ROLE->initialize( "MooseInteg::SomeRole", package => "MooseInteg::SomeRole" );
    my %ATTR;
    $ATTR{"bar"} = Moose::Meta::Role::Attribute->new( "bar",
        __hack_no_process_options => true,
        associated_role => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/MooseInteg/SomeRole.pm", line => "5", package => "MooseInteg::SomeRole", toolkit => "Mite", type => "role" },
        is => "rw",
        weak_ref => false,
        init_arg => "bar",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Object() },
        accessor => "bar",
        handles => { "quux" => "quux" },
    );
    delete $ATTR{"bar"}{original_options}{$_} for qw( associated_role );
    do {
        no warnings 'redefine';
        local *Moose::Meta::Attribute::install_accessors = sub {};
        $PACKAGE->add_attribute( $ATTR{"bar"} );
    };
    $PACKAGE->add_required_methods( "number" );
    for ( @MooseInteg::SomeRole::METHOD_MODIFIERS ) {
        my ( $type, $names, $code ) = @$_;
        $PACKAGE->${\"add_$type\_method_modifier"}( $_, $code ) for @$names;
    }
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&MooseInteg::SomeRole::meta,
            package_name => "MooseInteg::SomeRole",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_does_type_constraint( "MooseInteg::SomeRole" );
}

Moose::Util::find_meta( "MooseInteg::BaseClass" )->add_role( Moose::Util::find_meta( "MooseInteg::BaseClassRole" ) );

true;

