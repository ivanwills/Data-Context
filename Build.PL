use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Data::Context',
    license           => 'perl',
    dist_author       => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from => 'lib/Data/Context.pm',
    requires          => {
        'perl'                         => 5.008,
        'Class::Inspector'             => 0,
        'Clone'                        => 0,
        'Hash::Merge'                  => 0,
        'Moose'                        => 0,
        'Moose::Util::TypeConstraints' => 0,
        'Path::Class'                  => 0,
        'version'                      => 0,
    },
    build_requires => {
        'Test::More'       => 0,
        'Test::Warn'       => 0,
        'Test::NoWarnings' => 0,
        'AnyEvent'         => 0,
        'AnyEvent::HTTP'   => 0,
    },
    recommends => {
        'JSON'        => 0,
        'YAML::XS'    => 0,
        'XML::Simple' => 0,
        'Test::Spelling'     => 0,
        'Test::Perl::Critic' => 0,
        'Test::Kwalitee'     => 0,
        'Pod::Coverage'      => 0,
    },
    add_to_cleanup     => [ 'Data-Context-*' ],
    create_makefile_pl => 'traditional',
    create_license     => 1,
    meta_merge         => {
        resources => {
            repository => 'git://github.com/ivanwills/Data-Context.git',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Data::Context',
        },
    },
);

$builder->create_build_script();
