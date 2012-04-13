use strict;
use warnings;
use Test::More;# tests => 2;
use Path::Class;
use Data::Dumper qw/Dumper/;

use Data::Context;

my $path = file($0)->parent->subdir('dc');

test_creation();
test_getting();

done_testing;

sub test_creation {
    my $dc = Data::Context->new( path => "$path" );
    isa_ok $dc, 'Data::Context', 'get a new object correctly';

    eval { Data::Context->new };
    ok $@, "Requires path";
}

sub test_getting {
}