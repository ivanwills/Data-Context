#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 1 + 1;
use Test::NoWarnings;

BEGIN {
	use_ok( 'Data::Context' );
}

diag( "Testing Data::Context $Data::Context::VERSION, Perl $], $^X" );
