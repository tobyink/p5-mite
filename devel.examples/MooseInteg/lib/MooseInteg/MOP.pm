package MooseInteg::MOP;

use Moose ();
use Moose::Util ();
use Moose::Util::TypeConstraints ();
use constant { true => !!1, false => !!0 };

require "MooseInteg/BaseClass.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "MooseInteg::BaseClass", package => "MooseInteg::BaseClass" );
    my %ATTR;
    $ATTR{"foo"} = Moose::Meta::Attribute->new( "foo",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/MooseInteg/BaseClass.pm", line => "5", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
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
            definition_context => { context => "has declaration", description => "accessor MooseInteg::BaseClass::foo", file => "lib/MooseInteg/BaseClass.pm", line => "5", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
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
        definition_context => { context => "has declaration", file => "lib/MooseInteg/BaseClass.pm", line => "10", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
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
            definition_context => { context => "has declaration", description => "reader MooseInteg::BaseClass::hashy", file => "lib/MooseInteg/BaseClass.pm", line => "10", package => "MooseInteg::BaseClass", toolkit => "Mite", type => "class" },
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

require "MooseInteg/SomeRole.pm";

{
    my $PACKAGE = Moose::Meta::Role->initialize( "MooseInteg::SomeRole", package => "MooseInteg::SomeRole" );
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


true;

