use Test2::V0;
use Mite::Project ();

diag " ";
diag "================";
diag sprintf "PERL: %10s", $];
diag sprintf "MITE: %10s", 'Mite::Project'->VERSION;
diag "================";
diag " ";

my %modules = (
	runtime => { qw(
		namespace::autoclean 0
		Getopt::Kingpin 0.10
		Module::Pluggable 5.2
		Import::Into 0
		Path::Tiny 0.052
		Types::Path::Tiny 0
		Types::Standard 1.016000
		YAML::XS 0.41
		Class::XSAccessor 1.19
	) },
	testing => { qw(
		Test2::V0 0
		Test2::Tools::Spec 0
		Child 0.010
		File::Copy::Recursive 0.38
		Capture::Tiny 0.22
		Devel::Hide 0.0009
	) },
);

for my $stage ( qw/ runtime testing / ) {
	
	diag uc sprintf( '%s dependencies', $stage );
	diag " ";
	diag uc sprintf( '    %-24s %10s %10s', ' ', 'Want', 'Have' );
	
	for my $module ( sort { mycmp($a, $b) } keys %{ $modules{$stage} } ) {
		my $want_version = $modules{$stage}{$module};
		my $installed    = eval "require $module; 1";
		
		diag sprintf(
			'    %-24s %10s %10s',
			$module,
			$want_version,
			$installed ? $module->VERSION : 'MISSING',
		);
	}
	
	diag " ";
}

diag "ENVIRONMENT";
diag " ";
for my $key ( sort keys %ENV ) {
	next unless $key =~ /(MITE|PERL)/i;
	diag sprintf '    %-26s %-10s', $key, $ENV{$key};
}
diag " ";

sub mycmp {
	my ( $x, $y ) = @_;
	if ( $x =~ /^Test2/ and $y !~ /^Test2/ ) { return -1 };
	if ( $x !~ /^Test2/ and $y =~ /^Test2/ ) { return  1 };
	$x cmp $y;
}

ok 1;
done_testing;
