use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name       => 'Data::Context',
	license           => 'perl',
	dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from => 'lib/Data/Context.pm',
	requires          => {
		'perl'             => 5.008,
	},
	build_requires => {
		'Test::More'       => 0,
		'Test::NoWarnings' => 0,
	},
	add_to_cleanup     => [ 'Data-Context-*' ],
	create_makefile_pl => 'traditional',
	create_license     => 1,
	meta_merge => {
		resources => {
			repository => 'git://github.com/ivanwills/Data-Context.git',
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data::Context',
		},
	},
);

$builder->create_build_script();
