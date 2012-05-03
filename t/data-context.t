use strict;
use warnings;
use Test::More;
use Path::Class;
use Data::Dumper qw/Dumper/;
use AnyEvent;
use AnyEvent::HTTP;
use Test::Warn;

use Data::Context;

eval { require JSON };
plan skip_all => 'This test requires JSON to be installed to run' if $@;

my $path = file($0)->parent->subdir('dc');

test_creation();
test_getting();
test_getting_no_fallback();
test_loging();

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
    #diag Dumper $data;
    ok $data, "get some data";
}

sub test_getting_no_fallback {
    my $dc = Data::Context->new(
        path     => "$path",
        fallback => 0,
    );

    my $data = eval { $dc->get( 'data/with/deep/path', { test => { value => [qw/a b/] } } ) };
    #diag Dumper $data;
    ok !$data, "get no data";

    $data = eval { $dc->get( 'defaultable', { test => { value => [qw/a b/] } } ) };
    #diag Dumper $data;
    ok $data, "get default data";
}
sub test_loging {
    my $dc = Data::Context->new(
        path  => "$path",
        debug => 1,
    );

    warnings_like {$dc->log->debug('debug')} qr/DEBUG/, 'Can log debug';
    warnings_like {$dc->log->info ('info ')} qr/INFO/ , 'Can log info ';
    warnings_like {$dc->log->warn ('warn ')} qr/WARN/ , 'Can log warn ';
    warnings_like {$dc->log->error('error')} qr/ERROR/, 'Can log error';
    warnings_like {$dc->log->fatal('fatal')} qr/FATAL/, 'Can log fatal';

    $dc->debug(3);
    warning_is {$dc->log->debug('debug off')} undef, 'Can log debug';
}

sub get_data {
    my ($self, $data ) = @_;

    my $cv = AnyEvent->condvar;

    http_get $data->{url}, sub { $cv->send( length $_[0] ); };

    return $cv;
}
