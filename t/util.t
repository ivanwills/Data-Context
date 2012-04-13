use strict;
use warnings;
use Test::More tests => 6;
use Data::Dumper qw/Dumper/;

use Data::Context::Util qw/lol_path lol_itterate/;

my ($data, $tests) = get_data();
test_lol_path();
test_lol_itterate();

done_testing;

sub test_lol_path {

    for my $path ( keys %$tests ) {
        is lol_path($data, $path), $tests->{$path}, "lol_path '$path' returns '$tests->{$path}'";
    }
}

sub test_lol_itterate {
    my %result;
    lol_itterate(
        $data,
        sub {
            my ( $data, $path ) = @_;
            $result{$path} = $data;
        }
    );

    for my $path ( keys %$tests ) {
        is $result{$path}, $tests->{$path}, "lol_itterate saw '$path' had a value of '$tests->{$path}'";
    }
}

sub get_data {
    return (
        {
            a => "A",
            b => [
                {
                    b_a => "B A",
                },
                {
                    b_b => [
                        {
                            b_b_a => "B B A",
                        },
                        {
                            b_b_b => "B B B",
                        },
                    ],
                },
            ],
        },
        {
            'a'               => 'A',
            'b.0.b_a'         => "B A",
            'b.1.b_b.1.b_b_b' => "B B B",
        }
    );
}