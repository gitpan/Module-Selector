#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Module::Selector' );
}

diag( "Testing Module::Selector $Module::Selector::VERSION, Perl $], $^X" );
