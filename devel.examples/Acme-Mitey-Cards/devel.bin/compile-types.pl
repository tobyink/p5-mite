#!perl

use strict;
use warnings;
use FindBin qw( $Bin );
use lib "$Bin/../devel.lib";
use lib "$Bin/../lib";
use lib "$Bin/../../../lib";

use Type::Library::Compiler;

my $types_to_compile = 'Type::Library::Compiler'->parse_list(
	'Acme::Mitey::Cards::Types::Source=*'
);

my $compiler = 'Type::Library::Compiler'->new(
	types              => $types_to_compile,
	destination_module => 'Acme::Mitey::Cards::Types',
);

print $compiler->compile_to_file;
