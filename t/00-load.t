#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

use_ok('Data::Context');
use_ok('Data::Context::Actions');
use_ok('Data::Context::Instance');
use_ok('Data::Context::Util');

diag( "Testing Data::Context $Data::Context::VERSION, Perl $], $^X" );
done_testing;
