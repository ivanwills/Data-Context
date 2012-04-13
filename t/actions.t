use strict;
use warnings;
use Test::More tests => 3;
use Path::Class;

use Data::Context::Actions;

my $val = Data::Context::Actions->expand_vars( 'a', undef, 'a.b.c', { a => 1 } );
is $val, 1, 'Action expanded var';

$val = Data::Context::Actions->expand_vars( '#a#', undef, 'a.b.c', { a => 1 } );
is $val, 1, 'Action expanded var';

$val = Data::Context::Actions->expand_vars( {value => 'a'}, undef, 'a.b.c', { a => 1 } );
is $val, 1, 'Action expanded var';

done_testing();
