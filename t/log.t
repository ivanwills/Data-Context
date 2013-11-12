use strict;
use warnings;
use Test::More;
use Path::Class;
use Data::Dumper qw/Dumper/;
use IO::String;

use Data::Context::Log;

test_loging();

done_testing;

sub test_loging {
    my $last;
    my $fh = IO::String->new($last);

    my $log = Data::Context::Log->new(
        level => 1,
        fh    => $fh,
    );

    $log->debug('debug');
    like $last, qr/DEBUG/, 'Can log debug';
    $log->info ('info ');
    like $last, qr/INFO/ , 'Can log info ';
    $log->warn ('warn ');
    like $last, qr/WARN/ , 'Can log warn ';
    $log->error('error');
    like $last, qr/ERROR/, 'Can log error';
    $log->fatal('fatal');
    like $last, qr/FATAL/, 'Can log fatal';

    $log->level(3);
    $log->debug('debug off');
    unlike $last, qr/debug off/, 'Can log debug';
}

