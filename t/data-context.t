use strict;
use warnings;
use Test::More;# tests => 2;
use Path::Class;
use Data::Dumper qw/Dumper/;
use AnyEvent;
use AnyEvent::HTTP;

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
    my $dc = Data::Context->new(
        path     => "$path",
        fallback => 1,
    );
    my $data = $dc->get( 'data', { test => { value => [qw/a b/] } } );

    ok $data, "get some data";
    is $data->{hash}{straight_var}, 'b', "Variable set to 'b'";

    $data = $dc->get( 'data', { test => { value => [qw/a new_val/] } } );

    is $data->{hash}{straight_var}, 'new_val', "Variable set to 'new_val'";
    #diag Dumper $data;

    $data = eval { $dc->get( 'data/with/deep/path', { test => { value => [qw/a b/] } } ) };
    ok $data, "get some data";
}

sub get_data {
    my ($self, $data ) = @_;

    my $cv = AnyEvent->condvar;

    http_get $data->{url}, sub { $cv->send( length $_[0] ); };

    return $cv;
}
