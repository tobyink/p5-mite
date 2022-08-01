package Mite::MOP;

use Moose ();
use Moose::Util ();
use Moose::Util::TypeConstraints ();
use constant { true => !!1, false => !!0 };

require "Mite/App.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::App", package => "Mite::App" );
    my %ATTR;
    $ATTR{"commands"} = Moose::Meta::Attribute->new( "commands",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/App.pm", line => "22", package => "Mite::App", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "commands",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::HashRef()->parameterize( Types::Standard::Object() ) },
        reader => "commands",
        default => sub { {} },
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"commands"},
            name => "commands",
            body => \&Mite::App::commands,
            package_name => "Mite::App",
            definition_context => { context => "has declaration", description => "reader Mite::App::commands", file => "lib/Mite/App.pm", line => "22", package => "Mite::App", toolkit => "Mite", type => "class" },
        );
        $ATTR{"commands"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"commands"} );
    };
    $ATTR{"kingpin"} = Moose::Meta::Attribute->new( "kingpin",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/App.pm", line => "28", package => "Mite::App", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "kingpin",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Object() },
        reader => "kingpin",
        handles => { "_parse_argv" => "parse" },
        builder => "_build_kingpin",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"kingpin"},
            name => "kingpin",
            body => \&Mite::App::kingpin,
            package_name => "Mite::App",
            definition_context => { context => "has declaration", description => "reader Mite::App::kingpin", file => "lib/Mite/App.pm", line => "28", package => "Mite::App", toolkit => "Mite", type => "class" },
        );
        $ATTR{"kingpin"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "_parse_argv",
            attribute => $ATTR{"kingpin"},
            delegate_to_method => "parse",
            curried_arguments => [],
            body => \&Mite::App::_parse_argv,
            package_name => "Mite::App",
        );
        $ATTR{"kingpin"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"kingpin"} );
    };
    $ATTR{"project"} = Moose::Meta::Attribute->new( "project",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/App.pm", line => "36", package => "Mite::App", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "project",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteProject() },
        reader => "project",
        handles => { "config" => "config" },
        builder => "_build_project",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"project"},
            name => "project",
            body => \&Mite::App::project,
            package_name => "Mite::App",
            definition_context => { context => "has declaration", description => "reader Mite::App::project", file => "lib/Mite/App.pm", line => "36", package => "Mite::App", toolkit => "Mite", type => "class" },
        );
        $ATTR{"project"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "config",
            attribute => $ATTR{"project"},
            delegate_to_method => "config",
            curried_arguments => [],
            body => \&Mite::App::config,
            package_name => "Mite::App",
        );
        $ATTR{"project"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"project"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::App::meta,
            package_name => "Mite::App",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::App" );
}

require "Mite/App/Command.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::App::Command", package => "Mite::App::Command" );
    my %ATTR;
    $ATTR{"app"} = Moose::Meta::Attribute->new( "app",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/App/Command.pm", line => "11", package => "Mite::App::Command", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => true,
        init_arg => "app",
        required => true,
        type_constraint => do { require Types::Standard; Types::Standard::Object() },
        reader => "app",
        handles => { "config" => "config", "kingpin" => "kingpin", "project" => "project" },
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"app"},
            name => "app",
            body => \&Mite::App::Command::app,
            package_name => "Mite::App::Command",
            definition_context => { context => "has declaration", description => "reader Mite::App::Command::app", file => "lib/Mite/App/Command.pm", line => "11", package => "Mite::App::Command", toolkit => "Mite", type => "class" },
        );
        $ATTR{"app"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "config",
            attribute => $ATTR{"app"},
            delegate_to_method => "config",
            curried_arguments => [],
            body => \&Mite::App::Command::config,
            package_name => "Mite::App::Command",
        );
        $ATTR{"app"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "kingpin",
            attribute => $ATTR{"app"},
            delegate_to_method => "kingpin",
            curried_arguments => [],
            body => \&Mite::App::Command::kingpin,
            package_name => "Mite::App::Command",
        );
        $ATTR{"app"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "project",
            attribute => $ATTR{"app"},
            delegate_to_method => "project",
            curried_arguments => [],
            body => \&Mite::App::Command::project,
            package_name => "Mite::App::Command",
        );
        $ATTR{"app"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"app"} );
    };
    $ATTR{"kingpin_command"} = Moose::Meta::Attribute->new( "kingpin_command",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/App/Command.pm", line => "19", package => "Mite::App::Command", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "kingpin_command",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Object() },
        reader => "kingpin_command",
        builder => "_build_kingpin_command",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"kingpin_command"},
            name => "kingpin_command",
            body => \&Mite::App::Command::kingpin_command,
            package_name => "Mite::App::Command",
            definition_context => { context => "has declaration", description => "reader Mite::App::Command::kingpin_command", file => "lib/Mite/App/Command.pm", line => "19", package => "Mite::App::Command", toolkit => "Mite", type => "class" },
        );
        $ATTR{"kingpin_command"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"kingpin_command"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::App::Command::meta,
            package_name => "Mite::App::Command",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::App::Command" );
}

require "Mite/App/Command/clean.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::App::Command::clean", package => "Mite::App::Command::clean" );
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::App::Command::clean::meta,
            package_name => "Mite::App::Command::clean",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::App::Command::clean" );
}

require "Mite/App/Command/compile.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::App::Command::compile", package => "Mite::App::Command::compile" );
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::App::Command::compile::meta,
            package_name => "Mite::App::Command::compile",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::App::Command::compile" );
}

require "Mite/App/Command/init.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::App::Command::init", package => "Mite::App::Command::init" );
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::App::Command::init::meta,
            package_name => "Mite::App::Command::init",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::App::Command::init" );
}

require "Mite/App/Command/preview.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::App::Command::preview", package => "Mite::App::Command::preview" );
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::App::Command::preview::meta,
            package_name => "Mite::App::Command::preview",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::App::Command::preview" );
}

require "Mite/Attribute.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Attribute", package => "Mite::Attribute" );
    my %ATTR;
    $ATTR{"_order"} = Moose::Meta::Attribute->new( "_order",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "18", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => undef,
        accessor => "_order",
        builder => "_build__order",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"_order"},
            name => "_order",
            body => \&Mite::Attribute::_order,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::_order", file => "lib/Mite/Attribute.pm", line => "18", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"_order"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"_order"} );
    };
    $ATTR{"definition_context"} = Moose::Meta::Attribute->new( "definition_context",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "20", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "definition_context",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::HashRef() },
        accessor => "definition_context",
        default => sub { {} },
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"definition_context"},
            name => "definition_context",
            body => \&Mite::Attribute::definition_context,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::definition_context", file => "lib/Mite/Attribute.pm", line => "20", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"definition_context"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"definition_context"} );
    };
    $ATTR{"class"} = Moose::Meta::Attribute->new( "class",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "25", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => true,
        init_arg => "class",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteRole() },
        accessor => "class",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"class"},
            name => "class",
            body => \&Mite::Attribute::class,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::class", file => "lib/Mite/Attribute.pm", line => "25", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"class"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"class"} );
    };
    $ATTR{"compiling_class"} = Moose::Meta::Attribute->new( "compiling_class",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "30", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => undef,
        type_constraint => do { require Mite::Types; Mite::Types::MiteRole() },
        accessor => "compiling_class",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"compiling_class"},
            name => "compiling_class",
            body => \&Mite::Attribute::compiling_class,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::compiling_class", file => "lib/Mite/Attribute.pm", line => "30", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"compiling_class"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method->_new(
            name => "locally_set_compiling_class",
            body => \&Mite::Attribute::locally_set_compiling_class,
            package_name => "Mite::Attribute",
        );
        $ATTR{"compiling_class"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"compiling_class"} );
    };
    $ATTR{"_class_for_default"} = Moose::Meta::Attribute->new( "_class_for_default",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "41", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => true,
        init_arg => "_class_for_default",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteRole() },
        accessor => "_class_for_default",
        builder => "_build__class_for_default",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"_class_for_default"},
            name => "_class_for_default",
            body => \&Mite::Attribute::_class_for_default,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::_class_for_default", file => "lib/Mite/Attribute.pm", line => "41", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"_class_for_default"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"_class_for_default"} );
    };
    $ATTR{"name"} = Moose::Meta::Attribute->new( "name",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "43", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "name",
        required => true,
        type_constraint => do { require Types::Common::String; Types::Common::String::NonEmptyStr() },
        accessor => "name",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"name"},
            name => "name",
            body => \&Mite::Attribute::name,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::name", file => "lib/Mite/Attribute.pm", line => "43", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"name"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"name"} );
    };
    $ATTR{"init_arg"} = Moose::Meta::Attribute->new( "init_arg",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "52", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "init_arg",
        required => false,
        type_constraint => do { require Types::Common::String; require Types::Standard; Types::Common::String::NonEmptyStr() | Types::Standard::Undef() },
        accessor => "init_arg",
        default => $Mite::Attribute::__init_arg_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"init_arg"},
            name => "init_arg",
            body => \&Mite::Attribute::init_arg,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::init_arg", file => "lib/Mite/Attribute.pm", line => "52", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"init_arg"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"init_arg"} );
    };
    $ATTR{"required"} = Moose::Meta::Attribute->new( "required",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "54", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "required",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        accessor => "required",
        default => false,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"required"},
            name => "required",
            body => \&Mite::Attribute::required,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::required", file => "lib/Mite/Attribute.pm", line => "54", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"required"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"required"} );
    };
    $ATTR{"weak_ref"} = Moose::Meta::Attribute->new( "weak_ref",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "59", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "weak_ref",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        accessor => "weak_ref",
        default => false,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"weak_ref"},
            name => "weak_ref",
            body => \&Mite::Attribute::weak_ref,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::weak_ref", file => "lib/Mite/Attribute.pm", line => "59", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"weak_ref"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"weak_ref"} );
    };
    $ATTR{"is"} = Moose::Meta::Attribute->new( "is",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "64", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "is",
        required => false,
        type_constraint => do {
            require Type::Tiny;
            my $TYPE = Type::Tiny->new(
                display_name => "Enum[\"ro\",\"rw\",\"rwp\",\"lazy\",\"bare\"]",
                constraint   => sub { do {  (defined and !ref and m{\A(?:(?:bare|lazy|r(?:wp?|o)))\z}) } },
            );
            $TYPE;
        },
        accessor => "is",
        default => "bare",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"is"},
            name => "is",
            body => \&Mite::Attribute::is,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::is", file => "lib/Mite/Attribute.pm", line => "64", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"is"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"is"} );
    };
    $ATTR{"reader"} = Moose::Meta::Attribute->new( "reader",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "reader",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::Undef() },
        accessor => "reader",
        builder => "_build_reader",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"reader"},
            name => "reader",
            body => \&Mite::Attribute::reader,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::reader", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"reader"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"reader"} );
    };
    $ATTR{"writer"} = Moose::Meta::Attribute->new( "writer",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "writer",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::Undef() },
        accessor => "writer",
        builder => "_build_writer",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"writer"},
            name => "writer",
            body => \&Mite::Attribute::writer,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::writer", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"writer"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"writer"} );
    };
    $ATTR{"accessor"} = Moose::Meta::Attribute->new( "accessor",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "accessor",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::Undef() },
        accessor => "accessor",
        builder => "_build_accessor",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"accessor"},
            name => "accessor",
            body => \&Mite::Attribute::accessor,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::accessor", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"accessor"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"accessor"} );
    };
    $ATTR{"clearer"} = Moose::Meta::Attribute->new( "clearer",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "clearer",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::Undef() },
        accessor => "clearer",
        builder => "_build_clearer",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"clearer"},
            name => "clearer",
            body => \&Mite::Attribute::clearer,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::clearer", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"clearer"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"clearer"} );
    };
    $ATTR{"predicate"} = Moose::Meta::Attribute->new( "predicate",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "predicate",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::Undef() },
        accessor => "predicate",
        builder => "_build_predicate",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"predicate"},
            name => "predicate",
            body => \&Mite::Attribute::predicate,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::predicate", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"predicate"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"predicate"} );
    };
    $ATTR{"lvalue"} = Moose::Meta::Attribute->new( "lvalue",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "lvalue",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::Undef() },
        accessor => "lvalue",
        builder => "_build_lvalue",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"lvalue"},
            name => "lvalue",
            body => \&Mite::Attribute::lvalue,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::lvalue", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"lvalue"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"lvalue"} );
    };
    $ATTR{"local_writer"} = Moose::Meta::Attribute->new( "local_writer",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "local_writer",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::Undef() },
        accessor => "local_writer",
        builder => "_build_local_writer",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"local_writer"},
            name => "local_writer",
            body => \&Mite::Attribute::local_writer,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::local_writer", file => "lib/Mite/Attribute.pm", line => "69", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"local_writer"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"local_writer"} );
    };
    $ATTR{"isa"} = Moose::Meta::Attribute->new( "isa",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "75", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "bare", 
        weak_ref => false,
        init_arg => "isa",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Str() | Types::Standard::Ref() },
        reader => "_isa",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"isa"},
            name => "_isa",
            body => \&Mite::Attribute::_isa,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "reader Mite::Attribute::_isa", file => "lib/Mite/Attribute.pm", line => "75", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"isa"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"isa"} );
    };
    $ATTR{"does"} = Moose::Meta::Attribute->new( "does",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "80", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "bare", 
        weak_ref => false,
        init_arg => "does",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Str() | Types::Standard::Ref() },
        reader => "_does",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"does"},
            name => "_does",
            body => \&Mite::Attribute::_does,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "reader Mite::Attribute::_does", file => "lib/Mite/Attribute.pm", line => "80", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"does"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"does"} );
    };
    $ATTR{"type"} = Moose::Meta::Attribute->new( "type",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "85", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "type",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Object() | Types::Standard::Undef() },
        reader => "type",
        builder => "_build_type",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"type"},
            name => "type",
            body => \&Mite::Attribute::type,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "reader Mite::Attribute::type", file => "lib/Mite/Attribute.pm", line => "85", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"type"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"type"} );
    };
    $ATTR{"coerce"} = Moose::Meta::Attribute->new( "coerce",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "90", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "coerce",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        accessor => "coerce",
        default => false,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"coerce"},
            name => "coerce",
            body => \&Mite::Attribute::coerce,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::coerce", file => "lib/Mite/Attribute.pm", line => "90", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"coerce"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"coerce"} );
    };
    $ATTR{"default"} = Moose::Meta::Attribute->new( "default",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "95", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "default",
        required => false,
        type_constraint => do {
            require Type::Tiny;
            my $TYPE = Type::Tiny->new(
                display_name => "Undef|Str|CodeRef|ScalarRef|Dict[]|Tuple[]",
                constraint   => sub { do {  ((!defined($_)) or do {  defined($_) and do { ref(\$_) eq 'SCALAR' or ref(\(my $val = $_)) eq 'SCALAR' } } or (ref($_) eq 'CODE') or (ref($_) eq 'SCALAR' or ref($_) eq 'REF') or do {  (ref($_) eq 'HASH') and not(grep !/\A(?:)\z/, keys %{$_}) } or do {  (ref($_) eq 'ARRAY') and @{$_} == 0 }) } },
            );
            $TYPE;
        },
        accessor => "default",
        predicate => "has_default",
        documentation => "We support more possibilities than Moose!",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"default"},
            name => "default",
            body => \&Mite::Attribute::default,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::default", file => "lib/Mite/Attribute.pm", line => "95", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"default"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'predicate',
            attribute => $ATTR{"default"},
            name => "has_default",
            body => \&Mite::Attribute::has_default,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "predicate Mite::Attribute::has_default", file => "lib/Mite/Attribute.pm", line => "95", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"default"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"default"} );
    };
    $ATTR{"lazy"} = Moose::Meta::Attribute->new( "lazy",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "101", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "lazy",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        accessor => "lazy",
        default => false,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"lazy"},
            name => "lazy",
            body => \&Mite::Attribute::lazy,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::lazy", file => "lib/Mite/Attribute.pm", line => "101", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"lazy"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"lazy"} );
    };
    $ATTR{"coderef_default_variable"} = Moose::Meta::Attribute->new( "coderef_default_variable",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "113", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "coderef_default_variable",
        required => false,
        type_constraint => do { require Types::Common::String; Types::Common::String::NonEmptyStr() },
        accessor => "coderef_default_variable",
        default => $Mite::Attribute::__coderef_default_variable_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"coderef_default_variable"},
            name => "coderef_default_variable",
            body => \&Mite::Attribute::coderef_default_variable,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::coderef_default_variable", file => "lib/Mite/Attribute.pm", line => "113", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"coderef_default_variable"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"coderef_default_variable"} );
    };
    $ATTR{"trigger"} = Moose::Meta::Attribute->new( "trigger",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "115", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "trigger",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::CodeRef() },
        accessor => "trigger",
        predicate => "has_trigger",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"trigger"},
            name => "trigger",
            body => \&Mite::Attribute::trigger,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::trigger", file => "lib/Mite/Attribute.pm", line => "115", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"trigger"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'predicate',
            attribute => $ATTR{"trigger"},
            name => "has_trigger",
            body => \&Mite::Attribute::has_trigger,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "predicate Mite::Attribute::has_trigger", file => "lib/Mite/Attribute.pm", line => "115", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"trigger"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"trigger"} );
    };
    $ATTR{"builder"} = Moose::Meta::Attribute->new( "builder",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "115", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "builder",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::CodeRef() },
        accessor => "builder",
        predicate => "has_builder",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"builder"},
            name => "builder",
            body => \&Mite::Attribute::builder,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::builder", file => "lib/Mite/Attribute.pm", line => "115", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"builder"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'predicate',
            attribute => $ATTR{"builder"},
            name => "has_builder",
            body => \&Mite::Attribute::has_builder,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "predicate Mite::Attribute::has_builder", file => "lib/Mite/Attribute.pm", line => "115", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"builder"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"builder"} );
    };
    $ATTR{"clone"} = Moose::Meta::Attribute->new( "clone",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "120", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "bare", 
        weak_ref => false,
        init_arg => "clone",
        required => false,
        type_constraint => do { require Mite::Types; require Types::Standard; Mite::Types::MethodNameTemplate() | Mite::Types::One() | Types::Standard::CodeRef() | Types::Standard::Undef() },
        reader => "cloner_method",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"clone"},
            name => "cloner_method",
            body => \&Mite::Attribute::cloner_method,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "reader Mite::Attribute::cloner_method", file => "lib/Mite/Attribute.pm", line => "120", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"clone"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"clone"} );
    };
    $ATTR{"clone_on_read"} = Moose::Meta::Attribute->new( "clone_on_read",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "129", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "clone_on_read",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        coerce => true,
        reader => "clone_on_read",
        builder => "_build_clone_on_read",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"clone_on_read"},
            name => "clone_on_read",
            body => \&Mite::Attribute::clone_on_read,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "reader Mite::Attribute::clone_on_read", file => "lib/Mite/Attribute.pm", line => "129", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"clone_on_read"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"clone_on_read"} );
    };
    $ATTR{"clone_on_write"} = Moose::Meta::Attribute->new( "clone_on_write",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "129", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "clone_on_write",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        coerce => true,
        reader => "clone_on_write",
        builder => "_build_clone_on_write",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"clone_on_write"},
            name => "clone_on_write",
            body => \&Mite::Attribute::clone_on_write,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "reader Mite::Attribute::clone_on_write", file => "lib/Mite/Attribute.pm", line => "129", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"clone_on_write"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"clone_on_write"} );
    };
    $ATTR{"documentation"} = Moose::Meta::Attribute->new( "documentation",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "131", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "documentation",
        required => false,
        accessor => "documentation",
        predicate => "has_documentation",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"documentation"},
            name => "documentation",
            body => \&Mite::Attribute::documentation,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::documentation", file => "lib/Mite/Attribute.pm", line => "131", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"documentation"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'predicate',
            attribute => $ATTR{"documentation"},
            name => "has_documentation",
            body => \&Mite::Attribute::has_documentation,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "predicate Mite::Attribute::has_documentation", file => "lib/Mite/Attribute.pm", line => "131", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"documentation"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"documentation"} );
    };
    $ATTR{"handles"} = Moose::Meta::Attribute->new( "handles",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "135", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "handles",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::HandlesHash() },
        coerce => true,
        accessor => "handles",
        predicate => "has_handles",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"handles"},
            name => "handles",
            body => \&Mite::Attribute::handles,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::handles", file => "lib/Mite/Attribute.pm", line => "135", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"handles"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'predicate',
            attribute => $ATTR{"handles"},
            name => "has_handles",
            body => \&Mite::Attribute::has_handles,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "predicate Mite::Attribute::has_handles", file => "lib/Mite/Attribute.pm", line => "135", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"handles"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"handles"} );
    };
    $ATTR{"alias"} = Moose::Meta::Attribute->new( "alias",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "145", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "alias",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::AliasList() },
        coerce => true,
        accessor => "alias",
        default => $Mite::Attribute::__alias_DEFAULT__,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"alias"},
            name => "alias",
            body => \&Mite::Attribute::alias,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "accessor Mite::Attribute::alias", file => "lib/Mite/Attribute.pm", line => "145", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"alias"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"alias"} );
    };
    $ATTR{"alias_is_for"} = Moose::Meta::Attribute->new( "alias_is_for",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Attribute.pm", line => "147", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => undef,
        reader => "alias_is_for",
        builder => "_build_alias_is_for",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"alias_is_for"},
            name => "alias_is_for",
            body => \&Mite::Attribute::alias_is_for,
            package_name => "Mite::Attribute",
            definition_context => { context => "has declaration", description => "reader Mite::Attribute::alias_is_for", file => "lib/Mite/Attribute.pm", line => "147", package => "Mite::Attribute", toolkit => "Mite", type => "class" },
        );
        $ATTR{"alias_is_for"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"alias_is_for"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Attribute::meta,
            package_name => "Mite::Attribute",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Attribute" );
}

require "Mite/Class.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Class", package => "Mite::Class" );
    my %ATTR;
    $ATTR{"extends"} = Moose::Meta::Attribute->new( "extends",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Class.pm", line => "32", package => "Mite::Class", toolkit => "Mite", type => "class" },
        is => "bare", 
        weak_ref => false,
        init_arg => "extends",
        required => false,
        type_constraint => do { require Types::Standard; require Mite::Types; Types::Standard::ArrayRef()->parameterize( Mite::Types::ValidClassName() ) },
        accessor => "superclasses",
        default => $Mite::Class::__extends_DEFAULT__,
        lazy => false,
        trigger => sub { shift->_trigger_extends( @_ ) },
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"extends"},
            name => "superclasses",
            body => \&Mite::Class::superclasses,
            package_name => "Mite::Class",
            definition_context => { context => "has declaration", description => "accessor Mite::Class::superclasses", file => "lib/Mite/Class.pm", line => "32", package => "Mite::Class", toolkit => "Mite", type => "class" },
        );
        $ATTR{"extends"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"extends"} );
    };
    $ATTR{"parents"} = Moose::Meta::Attribute->new( "parents",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Class.pm", line => "35", package => "Mite::Class", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "parents",
        required => false,
        type_constraint => do { require Types::Standard; require Mite::Types; Types::Standard::ArrayRef()->parameterize( Mite::Types::MiteClass() ) },
        reader => "parents",
        clearer => "_clear_parents",
        builder => "_build_parents",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"parents"},
            name => "parents",
            body => \&Mite::Class::parents,
            package_name => "Mite::Class",
            definition_context => { context => "has declaration", description => "reader Mite::Class::parents", file => "lib/Mite/Class.pm", line => "35", package => "Mite::Class", toolkit => "Mite", type => "class" },
        );
        $ATTR{"parents"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'clearer',
            attribute => $ATTR{"parents"},
            name => "_clear_parents",
            body => \&Mite::Class::_clear_parents,
            package_name => "Mite::Class",
            definition_context => { context => "has declaration", description => "clearer Mite::Class::_clear_parents", file => "lib/Mite/Class.pm", line => "35", package => "Mite::Class", toolkit => "Mite", type => "class" },
        );
        $ATTR{"parents"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"parents"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Class::meta,
            package_name => "Mite::Class",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Class" );
}

require "Mite/Compiled.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Compiled", package => "Mite::Compiled" );
    my %ATTR;
    $ATTR{"file"} = Moose::Meta::Attribute->new( "file",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Compiled.pm", line => "23", package => "Mite::Compiled", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "file",
        required => false,
        type_constraint => do { require Types::Path::Tiny; Types::Path::Tiny::Path() },
        coerce => true,
        accessor => "file",
        default => $Mite::Compiled::__file_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"file"},
            name => "file",
            body => \&Mite::Compiled::file,
            package_name => "Mite::Compiled",
            definition_context => { context => "has declaration", description => "accessor Mite::Compiled::file", file => "lib/Mite/Compiled.pm", line => "23", package => "Mite::Compiled", toolkit => "Mite", type => "class" },
        );
        $ATTR{"file"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"file"} );
    };
    $ATTR{"source"} = Moose::Meta::Attribute->new( "source",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Compiled.pm", line => "25", package => "Mite::Compiled", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => true,
        init_arg => "source",
        required => true,
        type_constraint => do { require Mite::Types; Mite::Types::MiteSource() },
        reader => "source",
        handles => { "class_order" => "class_order", "classes" => "classes" },
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"source"},
            name => "source",
            body => \&Mite::Compiled::source,
            package_name => "Mite::Compiled",
            definition_context => { context => "has declaration", description => "reader Mite::Compiled::source", file => "lib/Mite/Compiled.pm", line => "25", package => "Mite::Compiled", toolkit => "Mite", type => "class" },
        );
        $ATTR{"source"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "class_order",
            attribute => $ATTR{"source"},
            delegate_to_method => "class_order",
            curried_arguments => [],
            body => \&Mite::Compiled::class_order,
            package_name => "Mite::Compiled",
        );
        $ATTR{"source"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "classes",
            attribute => $ATTR{"source"},
            delegate_to_method => "classes",
            curried_arguments => [],
            body => \&Mite::Compiled::classes,
            package_name => "Mite::Compiled",
        );
        $ATTR{"source"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"source"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Compiled::meta,
            package_name => "Mite::Compiled",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Compiled" );
}

require "Mite/Config.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Config", package => "Mite::Config" );
    my %ATTR;
    $ATTR{"mite_dir_name"} = Moose::Meta::Attribute->new( "mite_dir_name",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Config.pm", line => "11", package => "Mite::Config", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "mite_dir_name",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Str() },
        reader => "mite_dir_name",
        default => ".mite",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"mite_dir_name"},
            name => "mite_dir_name",
            body => \&Mite::Config::mite_dir_name,
            package_name => "Mite::Config",
            definition_context => { context => "has declaration", description => "reader Mite::Config::mite_dir_name", file => "lib/Mite/Config.pm", line => "11", package => "Mite::Config", toolkit => "Mite", type => "class" },
        );
        $ATTR{"mite_dir_name"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"mite_dir_name"} );
    };
    $ATTR{"mite_dir"} = Moose::Meta::Attribute->new( "mite_dir",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Config.pm", line => "25", package => "Mite::Config", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "mite_dir",
        required => false,
        type_constraint => do { require Types::Path::Tiny; Types::Path::Tiny::Path() },
        coerce => true,
        reader => "mite_dir",
        default => $Mite::Config::__mite_dir_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"mite_dir"},
            name => "mite_dir",
            body => \&Mite::Config::mite_dir,
            package_name => "Mite::Config",
            definition_context => { context => "has declaration", description => "reader Mite::Config::mite_dir", file => "lib/Mite/Config.pm", line => "25", package => "Mite::Config", toolkit => "Mite", type => "class" },
        );
        $ATTR{"mite_dir"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"mite_dir"} );
    };
    $ATTR{"config_file"} = Moose::Meta::Attribute->new( "config_file",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Config.pm", line => "35", package => "Mite::Config", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "config_file",
        required => false,
        type_constraint => do { require Types::Path::Tiny; Types::Path::Tiny::Path() },
        coerce => true,
        reader => "config_file",
        default => $Mite::Config::__config_file_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"config_file"},
            name => "config_file",
            body => \&Mite::Config::config_file,
            package_name => "Mite::Config",
            definition_context => { context => "has declaration", description => "reader Mite::Config::config_file", file => "lib/Mite/Config.pm", line => "35", package => "Mite::Config", toolkit => "Mite", type => "class" },
        );
        $ATTR{"config_file"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"config_file"} );
    };
    $ATTR{"data"} = Moose::Meta::Attribute->new( "data",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Config.pm", line => "44", package => "Mite::Config", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "data",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::HashRef() },
        accessor => "data",
        default => $Mite::Config::__data_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"data"},
            name => "data",
            body => \&Mite::Config::data,
            package_name => "Mite::Config",
            definition_context => { context => "has declaration", description => "accessor Mite::Config::data", file => "lib/Mite/Config.pm", line => "44", package => "Mite::Config", toolkit => "Mite", type => "class" },
        );
        $ATTR{"data"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"data"} );
    };
    $ATTR{"search_for_mite_dir"} = Moose::Meta::Attribute->new( "search_for_mite_dir",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Config.pm", line => "46", package => "Mite::Config", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "search_for_mite_dir",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        accessor => "search_for_mite_dir",
        default => true,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"search_for_mite_dir"},
            name => "search_for_mite_dir",
            body => \&Mite::Config::search_for_mite_dir,
            package_name => "Mite::Config",
            definition_context => { context => "has declaration", description => "accessor Mite::Config::search_for_mite_dir", file => "lib/Mite/Config.pm", line => "46", package => "Mite::Config", toolkit => "Mite", type => "class" },
        );
        $ATTR{"search_for_mite_dir"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"search_for_mite_dir"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Config::meta,
            package_name => "Mite::Config",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Config" );
}

require "Mite/MakeMaker.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::MakeMaker", package => "Mite::MakeMaker" );
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::MakeMaker::meta,
            package_name => "Mite::MakeMaker",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::MakeMaker" );
}

require "Mite/Project.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Project", package => "Mite::Project" );
    my %ATTR;
    $ATTR{"sources"} = Moose::Meta::Attribute->new( "sources",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Project.pm", line => "14", package => "Mite::Project", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "sources",
        required => false,
        type_constraint => do { require Types::Standard; require Mite::Types; Types::Standard::HashRef()->parameterize( Mite::Types::MiteSource() ) },
        reader => "sources",
        default => $Mite::Project::__sources_DEFAULT__,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"sources"},
            name => "sources",
            body => \&Mite::Project::sources,
            package_name => "Mite::Project",
            definition_context => { context => "has declaration", description => "reader Mite::Project::sources", file => "lib/Mite/Project.pm", line => "14", package => "Mite::Project", toolkit => "Mite", type => "class" },
        );
        $ATTR{"sources"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"sources"} );
    };
    $ATTR{"config"} = Moose::Meta::Attribute->new( "config",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Project.pm", line => "24", package => "Mite::Project", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "config",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteConfig() },
        reader => "config",
        default => $Mite::Project::__config_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"config"},
            name => "config",
            body => \&Mite::Project::config,
            package_name => "Mite::Project",
            definition_context => { context => "has declaration", description => "reader Mite::Project::config", file => "lib/Mite/Project.pm", line => "24", package => "Mite::Project", toolkit => "Mite", type => "class" },
        );
        $ATTR{"config"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"config"} );
    };
    $ATTR{"_module_fakeout_namespace"} = Moose::Meta::Attribute->new( "_module_fakeout_namespace",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Project.pm", line => "26", package => "Mite::Project", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "_module_fakeout_namespace",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Str() | Types::Standard::Undef() },
        accessor => "_module_fakeout_namespace",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"_module_fakeout_namespace"},
            name => "_module_fakeout_namespace",
            body => \&Mite::Project::_module_fakeout_namespace,
            package_name => "Mite::Project",
            definition_context => { context => "has declaration", description => "accessor Mite::Project::_module_fakeout_namespace", file => "lib/Mite/Project.pm", line => "26", package => "Mite::Project", toolkit => "Mite", type => "class" },
        );
        $ATTR{"_module_fakeout_namespace"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"_module_fakeout_namespace"} );
    };
    $ATTR{"debug"} = Moose::Meta::Attribute->new( "debug",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Project.pm", line => "30", package => "Mite::Project", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "debug",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        accessor => "debug",
        default => false,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"debug"},
            name => "debug",
            body => \&Mite::Project::debug,
            package_name => "Mite::Project",
            definition_context => { context => "has declaration", description => "accessor Mite::Project::debug", file => "lib/Mite/Project.pm", line => "30", package => "Mite::Project", toolkit => "Mite", type => "class" },
        );
        $ATTR{"debug"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"debug"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Project::meta,
            package_name => "Mite::Project",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Project" );
}

require "Mite/Role.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Role", package => "Mite::Role" );
    my %ATTR;
    $ATTR{"attributes"} = Moose::Meta::Attribute->new( "attributes",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "21", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "attributes",
        required => false,
        type_constraint => do { require Types::Standard; require Mite::Types; Types::Standard::HashRef()->parameterize( Mite::Types::MiteAttribute() ) },
        reader => "attributes",
        default => $Mite::Role::__attributes_DEFAULT__,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"attributes"},
            name => "attributes",
            body => \&Mite::Role::attributes,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "reader Mite::Role::attributes", file => "lib/Mite/Role.pm", line => "21", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"attributes"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"attributes"} );
    };
    $ATTR{"name"} = Moose::Meta::Attribute->new( "name",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "23", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "name",
        required => true,
        type_constraint => do { require Mite::Types; Mite::Types::ValidClassName() },
        reader => "name",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"name"},
            name => "name",
            body => \&Mite::Role::name,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "reader Mite::Role::name", file => "lib/Mite/Role.pm", line => "23", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"name"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"name"} );
    };
    $ATTR{"shim_name"} = Moose::Meta::Attribute->new( "shim_name",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "35", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => "shim_name",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::ValidClassName() },
        accessor => "shim_name",
        builder => "_build_shim_name",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"shim_name"},
            name => "shim_name",
            body => \&Mite::Role::shim_name,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "accessor Mite::Role::shim_name", file => "lib/Mite/Role.pm", line => "35", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"shim_name"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"shim_name"} );
    };
    $ATTR{"source"} = Moose::Meta::Attribute->new( "source",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "37", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => true,
        init_arg => "source",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteSource() },
        accessor => "source",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"source"},
            name => "source",
            body => \&Mite::Role::source,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "accessor Mite::Role::source", file => "lib/Mite/Role.pm", line => "37", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"source"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"source"} );
    };
    $ATTR{"roles"} = Moose::Meta::Attribute->new( "roles",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "46", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "roles",
        required => false,
        type_constraint => do { require Types::Standard; require Mite::Types; Types::Standard::ArrayRef()->parameterize( Mite::Types::MiteRole() ) },
        reader => "roles",
        builder => "_build_roles",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"roles"},
            name => "roles",
            body => \&Mite::Role::roles,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "reader Mite::Role::roles", file => "lib/Mite/Role.pm", line => "46", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"roles"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"roles"} );
    };
    $ATTR{"imported_functions"} = Moose::Meta::Attribute->new( "imported_functions",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "51", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "imported_functions",
        required => false,
        type_constraint => do {
            require Type::Tiny;
            my $TYPE = Type::Tiny->new(
                display_name => "Map[MethodName,Str]",
                constraint   => sub { do {  (ref($_) eq 'HASH') and do { my $ok = 1; for my $v (values %{$_}) { ($ok = 0, last) unless do {  defined($v) and do { ref(\$v) eq 'SCALAR' or ref(\(my $val = $v)) eq 'SCALAR' } } }; for my $k (keys %{$_}) { ($ok = 0, last) unless ((do {  defined($k) and do { ref(\$k) eq 'SCALAR' or ref(\(my $val = $k)) eq 'SCALAR' } }) && (do { local $_ = $k;  /\A[^\W0-9]\w*\z/  })) }; $ok } } },
            );
            $TYPE;
        },
        reader => "imported_functions",
        builder => "_build_imported_functions",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"imported_functions"},
            name => "imported_functions",
            body => \&Mite::Role::imported_functions,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "reader Mite::Role::imported_functions", file => "lib/Mite/Role.pm", line => "51", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"imported_functions"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"imported_functions"} );
    };
    $ATTR{"required_methods"} = Moose::Meta::Attribute->new( "required_methods",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "56", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "required_methods",
        required => false,
        type_constraint => do { require Types::Standard; require Mite::Types; Types::Standard::ArrayRef()->parameterize( Mite::Types::MethodName() ) },
        reader => "required_methods",
        builder => "_build_required_methods",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"required_methods"},
            name => "required_methods",
            body => \&Mite::Role::required_methods,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "reader Mite::Role::required_methods", file => "lib/Mite/Role.pm", line => "56", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"required_methods"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"required_methods"} );
    };
    $ATTR{"method_signatures"} = Moose::Meta::Attribute->new( "method_signatures",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Role.pm", line => "61", package => "Mite::Role", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "method_signatures",
        required => false,
        type_constraint => do {
            require Type::Tiny;
            my $TYPE = Type::Tiny->new(
                display_name => "Map[MethodName,Mite::Signature]",
                constraint   => sub { do {  (ref($_) eq 'HASH') and do { my $ok = 1; for my $v (values %{$_}) { ($ok = 0, last) unless (do { use Scalar::Util (); Scalar::Util::blessed($v) and $v->isa(q[Mite::Signature]) }) }; for my $k (keys %{$_}) { ($ok = 0, last) unless ((do {  defined($k) and do { ref(\$k) eq 'SCALAR' or ref(\(my $val = $k)) eq 'SCALAR' } }) && (do { local $_ = $k;  /\A[^\W0-9]\w*\z/  })) }; $ok } } },
            );
            $TYPE;
        },
        reader => "method_signatures",
        builder => "_build_method_signatures",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"method_signatures"},
            name => "method_signatures",
            body => \&Mite::Role::method_signatures,
            package_name => "Mite::Role",
            definition_context => { context => "has declaration", description => "reader Mite::Role::method_signatures", file => "lib/Mite/Role.pm", line => "61", package => "Mite::Role", toolkit => "Mite", type => "class" },
        );
        $ATTR{"method_signatures"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"method_signatures"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Role::meta,
            package_name => "Mite::Role",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Role" );
}

require "Mite/Role/Tiny.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Role::Tiny", package => "Mite::Role::Tiny" );
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Role::Tiny::meta,
            package_name => "Mite::Role::Tiny",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Role::Tiny" );
}

require "Mite/Signature.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Signature", package => "Mite::Signature" );
    my %ATTR;
    $ATTR{"class"} = Moose::Meta::Attribute->new( "class",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "11", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => true,
        init_arg => "class",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteClass() },
        reader => "class",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"class"},
            name => "class",
            body => \&Mite::Signature::class,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::class", file => "lib/Mite/Signature.pm", line => "11", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"class"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"class"} );
    };
    $ATTR{"compiling_class"} = Moose::Meta::Attribute->new( "compiling_class",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "16", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => false,
        init_arg => undef,
        type_constraint => do { require Mite::Types; Mite::Types::MiteRole() },
        accessor => "compiling_class",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"compiling_class"},
            name => "compiling_class",
            body => \&Mite::Signature::compiling_class,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "accessor Mite::Signature::compiling_class", file => "lib/Mite/Signature.pm", line => "16", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"compiling_class"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method->_new(
            name => "locally_set_compiling_class",
            body => \&Mite::Signature::locally_set_compiling_class,
            package_name => "Mite::Signature",
        );
        $ATTR{"compiling_class"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"compiling_class"} );
    };
    $ATTR{"method_name"} = Moose::Meta::Attribute->new( "method_name",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "22", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "method_name",
        required => true,
        type_constraint => do { require Types::Standard; Types::Standard::Str() },
        reader => "method_name",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"method_name"},
            name => "method_name",
            body => \&Mite::Signature::method_name,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::method_name", file => "lib/Mite/Signature.pm", line => "22", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"method_name"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"method_name"} );
    };
    $ATTR{"named"} = Moose::Meta::Attribute->new( "named",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "27", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "named",
        required => false,
        type_constraint => do {
            require Type::Tiny;
            my $TYPE = Type::Tiny->new(
                display_name => "ArrayRef",
                constraint   => sub { (ref($_) eq 'ARRAY') },
            );
            require Types::Standard;
            $TYPE->coercion->add_type_coercions(
                Types::Standard::Any(),
                sub { ((ref($_) eq 'ARRAY')) ? $_ : ((ref($_) eq 'HASH')) ? scalar(do { [%$_] }) : $_ },
            );
            $TYPE->coercion->freeze;
            $TYPE;
        },
        reader => "named",
        predicate => "is_named",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"named"},
            name => "named",
            body => \&Mite::Signature::named,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::named", file => "lib/Mite/Signature.pm", line => "27", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"named"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'predicate',
            attribute => $ATTR{"named"},
            name => "is_named",
            body => \&Mite::Signature::is_named,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "predicate Mite::Signature::is_named", file => "lib/Mite/Signature.pm", line => "27", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"named"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"named"} );
    };
    $ATTR{"positional"} = Moose::Meta::Attribute->new( "positional",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "32", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "positional",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::ArrayRef() },
        reader => "positional",
        predicate => "is_positional",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"positional"},
            name => "positional",
            body => \&Mite::Signature::positional,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::positional", file => "lib/Mite/Signature.pm", line => "32", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"positional"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'predicate',
            attribute => $ATTR{"positional"},
            name => "is_positional",
            body => \&Mite::Signature::is_positional,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "predicate Mite::Signature::is_positional", file => "lib/Mite/Signature.pm", line => "32", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"positional"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $ALIAS = Moose::Meta::Method->_new(
            name => "pos",
            body => \&Mite::Signature::pos,
            package_name => "Mite::Signature",
        );
        $ATTR{"positional"}->associate_method( $ALIAS );
        $PACKAGE->add_method( $ALIAS->name, $ALIAS );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"positional"} );
    };
    $ATTR{"method"} = Moose::Meta::Attribute->new( "method",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "38", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "method",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        reader => "method",
        default => true,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"method"},
            name => "method",
            body => \&Mite::Signature::method,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::method", file => "lib/Mite/Signature.pm", line => "38", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"method"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"method"} );
    };
    $ATTR{"head"} = Moose::Meta::Attribute->new( "head",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "46", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "head",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::ArrayRef() | Types::Standard::Int() },
        reader => "head",
        builder => "_build_head",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"head"},
            name => "head",
            body => \&Mite::Signature::head,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::head", file => "lib/Mite/Signature.pm", line => "46", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"head"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"head"} );
    };
    $ATTR{"tail"} = Moose::Meta::Attribute->new( "tail",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "48", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "tail",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::ArrayRef() | Types::Standard::Int() },
        reader => "tail",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"tail"},
            name => "tail",
            body => \&Mite::Signature::tail,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::tail", file => "lib/Mite/Signature.pm", line => "48", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"tail"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"tail"} );
    };
    $ATTR{"named_to_list"} = Moose::Meta::Attribute->new( "named_to_list",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "52", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "named_to_list",
        required => false,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() | Types::Standard::ArrayRef() },
        reader => "named_to_list",
        default => "",
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"named_to_list"},
            name => "named_to_list",
            body => \&Mite::Signature::named_to_list,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::named_to_list", file => "lib/Mite/Signature.pm", line => "52", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"named_to_list"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"named_to_list"} );
    };
    $ATTR{"compiler"} = Moose::Meta::Attribute->new( "compiler",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "57", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => undef,
        type_constraint => do { require Types::Standard; Types::Standard::Object() },
        reader => "compiler",
        handles => { "has_head" => "has_head", "has_slurpy" => "has_slurpy", "has_tail" => "has_tail" },
        builder => "_build_compiler",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"compiler"},
            name => "compiler",
            body => \&Mite::Signature::compiler,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::compiler", file => "lib/Mite/Signature.pm", line => "57", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"compiler"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "has_head",
            attribute => $ATTR{"compiler"},
            delegate_to_method => "has_head",
            curried_arguments => [],
            body => \&Mite::Signature::has_head,
            package_name => "Mite::Signature",
        );
        $ATTR{"compiler"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "has_slurpy",
            attribute => $ATTR{"compiler"},
            delegate_to_method => "has_slurpy",
            curried_arguments => [],
            body => \&Mite::Signature::has_slurpy,
            package_name => "Mite::Signature",
        );
        $ATTR{"compiler"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    {
        my $DELEGATION = Moose::Meta::Method::Delegation->new(
            name => "has_tail",
            attribute => $ATTR{"compiler"},
            delegate_to_method => "has_tail",
            curried_arguments => [],
            body => \&Mite::Signature::has_tail,
            package_name => "Mite::Signature",
        );
        $ATTR{"compiler"}->associate_method( $DELEGATION );
        $PACKAGE->add_method( $DELEGATION->name, $DELEGATION );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"compiler"} );
    };
    $ATTR{"should_bless"} = Moose::Meta::Attribute->new( "should_bless",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Signature.pm", line => "68", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => undef,
        type_constraint => do { require Types::Standard; Types::Standard::Bool() },
        reader => "should_bless",
        builder => "_build_should_bless",
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"should_bless"},
            name => "should_bless",
            body => \&Mite::Signature::should_bless,
            package_name => "Mite::Signature",
            definition_context => { context => "has declaration", description => "reader Mite::Signature::should_bless", file => "lib/Mite/Signature.pm", line => "68", package => "Mite::Signature", toolkit => "Mite", type => "class" },
        );
        $ATTR{"should_bless"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"should_bless"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Signature::meta,
            package_name => "Mite::Signature",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Signature" );
}

require "Mite/Source.pm";

{
    my $PACKAGE = Moose::Meta::Class->initialize( "Mite::Source", package => "Mite::Source" );
    my %ATTR;
    $ATTR{"file"} = Moose::Meta::Attribute->new( "file",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Source.pm", line => "11", package => "Mite::Source", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "file",
        required => true,
        type_constraint => do { require Types::Path::Tiny; Types::Path::Tiny::Path() },
        coerce => true,
        reader => "file",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"file"},
            name => "file",
            body => \&Mite::Source::file,
            package_name => "Mite::Source",
            definition_context => { context => "has declaration", description => "reader Mite::Source::file", file => "lib/Mite/Source.pm", line => "11", package => "Mite::Source", toolkit => "Mite", type => "class" },
        );
        $ATTR{"file"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"file"} );
    };
    $ATTR{"classes"} = Moose::Meta::Attribute->new( "classes",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Source.pm", line => "20", package => "Mite::Source", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "classes",
        required => false,
        type_constraint => do { require Types::Standard; require Mite::Types; Types::Standard::HashRef()->parameterize( Mite::Types::MiteClass() ) },
        reader => "classes",
        default => $Mite::Source::__classes_DEFAULT__,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"classes"},
            name => "classes",
            body => \&Mite::Source::classes,
            package_name => "Mite::Source",
            definition_context => { context => "has declaration", description => "reader Mite::Source::classes", file => "lib/Mite/Source.pm", line => "20", package => "Mite::Source", toolkit => "Mite", type => "class" },
        );
        $ATTR{"classes"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"classes"} );
    };
    $ATTR{"class_order"} = Moose::Meta::Attribute->new( "class_order",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Source.pm", line => "25", package => "Mite::Source", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "class_order",
        required => false,
        type_constraint => do { require Types::Standard; require Types::Common::String; Types::Standard::ArrayRef()->parameterize( Types::Common::String::NonEmptyStr() ) },
        reader => "class_order",
        default => $Mite::Source::__class_order_DEFAULT__,
        lazy => false,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"class_order"},
            name => "class_order",
            body => \&Mite::Source::class_order,
            package_name => "Mite::Source",
            definition_context => { context => "has declaration", description => "reader Mite::Source::class_order", file => "lib/Mite/Source.pm", line => "25", package => "Mite::Source", toolkit => "Mite", type => "class" },
        );
        $ATTR{"class_order"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"class_order"} );
    };
    $ATTR{"compiled"} = Moose::Meta::Attribute->new( "compiled",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Source.pm", line => "34", package => "Mite::Source", toolkit => "Mite", type => "class" },
        is => "ro", 
        weak_ref => false,
        init_arg => "compiled",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteCompiled() },
        reader => "compiled",
        default => $Mite::Source::__compiled_DEFAULT__,
        lazy => true,
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'reader',
            attribute => $ATTR{"compiled"},
            name => "compiled",
            body => \&Mite::Source::compiled,
            package_name => "Mite::Source",
            definition_context => { context => "has declaration", description => "reader Mite::Source::compiled", file => "lib/Mite/Source.pm", line => "34", package => "Mite::Source", toolkit => "Mite", type => "class" },
        );
        $ATTR{"compiled"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"compiled"} );
    };
    $ATTR{"project"} = Moose::Meta::Attribute->new( "project",
        __hack_no_process_options => true,
        associated_class => $PACKAGE,
        definition_context => { context => "has declaration", file => "lib/Mite/Source.pm", line => "36", package => "Mite::Source", toolkit => "Mite", type => "class" },
        is => "rw", 
        weak_ref => true,
        init_arg => "project",
        required => false,
        type_constraint => do { require Mite::Types; Mite::Types::MiteProject() },
        accessor => "project",
    );
    {
        my $ACCESSOR = Moose::Meta::Method::Accessor->new(
            accessor_type => 'accessor',
            attribute => $ATTR{"project"},
            name => "project",
            body => \&Mite::Source::project,
            package_name => "Mite::Source",
            definition_context => { context => "has declaration", description => "accessor Mite::Source::project", file => "lib/Mite/Source.pm", line => "36", package => "Mite::Source", toolkit => "Mite", type => "class" },
        );
        $ATTR{"project"}->associate_method( $ACCESSOR );
        $PACKAGE->add_method( $ACCESSOR->name, $ACCESSOR );
    }
    do {
    	no warnings 'redefine';
    	local *Moose::Meta::Attribute::install_accessors = sub {};
    	$PACKAGE->add_attribute( $ATTR{"project"} );
    };
    $PACKAGE->add_method(
        "meta" => Moose::Meta::Method::Meta->_new(
            name => "meta",
            body => \&Mite::Source::meta,
            package_name => "Mite::Source",
        ),
    );
    Moose::Util::TypeConstraints::find_or_create_isa_type_constraint( "Mite::Source" );
}

Moose::Util::find_meta( "Mite::App::Command::clean" )->superclasses( "Mite::App::Command" );
Moose::Util::find_meta( "Mite::App::Command::compile" )->superclasses( "Mite::App::Command" );
Moose::Util::find_meta( "Mite::App::Command::init" )->superclasses( "Mite::App::Command" );
Moose::Util::find_meta( "Mite::App::Command::preview" )->superclasses( "Mite::App::Command" );
Moose::Util::find_meta( "Mite::Class" )->superclasses( "Mite::Role" );
Moose::Util::find_meta( "Mite::Role::Tiny" )->superclasses( "Mite::Role" );

true;

