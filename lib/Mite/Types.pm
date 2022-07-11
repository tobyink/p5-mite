package Mite::Types;

use strict;
use warnings;
use Type::Library 1.012 -base, -declare => qw(
	One MethodName MethodNameTemplate ValidClassName HandlesHash AliasList
	MiteRole MiteClass MiteAttribute MiteProject MiteSource MiteCompiled MiteConfig
);

use Types::Standard -types;
use Types::Common::String -types;
use Types::Common::Numeric -types;

__PACKAGE__->add_type(
	name      => One,
	parent    => Enum[ "1" ],
);

__PACKAGE__->add_type(
	name      => MethodName,
	parent    => Str->where( q{ /\A[^\W0-9]\w*\z/ } ),
);

__PACKAGE__->add_type(
	name      => MethodNameTemplate,
	parent    => MethodName | Str->where( q{ /\%/ } ),
);

__PACKAGE__->add_type(
	name      => ValidClassName,
	parent    => Str->where( q{ /\A[^\W0-9]\w*(?:::[^\W0-9]\w*)*\z/ } ),
);

__PACKAGE__->add_type(
	name      => MiteProject,
	parent    => InstanceOf[ 'Mite::Project' ],
	display_name => 'Mite::Project',
);

__PACKAGE__->add_type(
	name      => MiteConfig,
	parent    => InstanceOf[ 'Mite::Config' ],
	display_name => 'Mite::Config',
);

__PACKAGE__->add_type(
	name      => MiteSource,
	parent    => InstanceOf[ 'Mite::Source' ],
	display_name => 'Mite::Source',
);

__PACKAGE__->add_type(
	name      => MiteCompiled,
	parent    => InstanceOf[ 'Mite::Compiled' ],
	display_name => 'Mite::Compiled',
);

__PACKAGE__->add_type(
	name      => MiteRole,
	parent    => InstanceOf[ 'Mite::Role' ],
	display_name => 'Mite::Role',
);

__PACKAGE__->add_type(
	name      => MiteClass,
	parent    => InstanceOf[ 'Mite::Class' ],
	display_name => 'Mite::Class',
);

__PACKAGE__->add_type(
	name      => MiteAttribute,
	parent    => InstanceOf[ 'Mite::Attribute' ],
	display_name => 'Mite::Attribute',
);

__PACKAGE__->add_type(
	name      => HandlesHash,
	parent    => Map[ MethodNameTemplate, MethodName ],
)->coercion->add_type_coercions(
	ArrayRef, q{ +{ map { $_ => $_ } @$_ } },
);

__PACKAGE__->add_type(
	name      => AliasList,
	parent    => ArrayRef[ MethodNameTemplate ],
)->coercion->add_type_coercions(
	Str,      q{ [$_] },
	Undef,    q{ [] },
);

__PACKAGE__->make_immutable;

1;
