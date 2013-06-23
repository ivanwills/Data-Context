use strict;
use warnings;
use Test::More;# tests => 2;
use Path::Class;
use Data::Dumper qw/Dumper/;

use Data::Context;
use Data::Context::Instance;
my $dc = Data::Context->new(
    path => file($0)->parent->subdir('dc') . '',
);

my $have_json = eval {require JSON        };
my $have_yaml = eval {require YAML::XS    };
my $have_xml  = eval {require XML::Simple };

test_object();
test_sort();

done_testing;

sub test_object {
    my $dci;
    SKIP: {
        skip "Need JSON to run" => 1 unless $have_json;

        $dci = Data::Context::Instance->new(
            path => 'data',
            file => file($0)->parent->file('dc/data.dc.js'),
            type => 'js',
            dc   => $dc,
        )->init;

        ok $dci, 'get an object back';
        #diag Dumper $dci->raw;
        #diag Dumper $dci->actions;
        #diag Dumper $dci->get_data({test=>{value=>['replace']}});
    }

    SKIP: {
        skip "Need YAML::XS to run" => 1 unless $have_yaml;

        $dci = Data::Context::Instance->new(
            path => 'deep/child',
            file => file($0)->parent->file('dc/deep/child.dc.yml'),
            type => 'yaml',
            dc   => $dc,
        )->init;

        ok $dci, 'get an object back';
        is $dci->raw->{basic}, 'text', 'Get data from parent config';
        #diag Dumper $dci->raw;
    }

    SKIP: {
        skip "Need XML::Simple to run" => 1 unless $have_xml;

        $dci = Data::Context::Instance->new(
            path => 'data',
            file => file($0)->parent->file('dc/_default.dc.xml'),
            type => 'xml',
            dc   => $dc,
        )->init;

        ok $dci, 'get data for xml';
        #diag Dumper $dci->raw;
        #diag Dumper $dci->actions;
        #diag Dumper $dci->get_data({test=>{value=>['replace']}});
    }
}

sub test_sort {
    my @tests = (
        {
            four  => { found => 1, order => -1 },
            two   => { found => 2, order => undef },
            three => { found => 3, order => undef },
            one   => { found => 4, order => 1 },
        } => [ qw/ one two three four / ],
    );
    my $sorted = [ Data::Context::Instance::_sort_optional( $tests[0] ) ];

    is_deeply $sorted, $tests[1], "Sorted correctly"
        or diag Dumper $sorted, $tests[1];
}
