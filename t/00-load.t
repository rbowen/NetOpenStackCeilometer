#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

BEGIN {
    use_ok( 'Net::OpenStack::Ceilometer' ) || print "Bail out!\n";
}

my $a = Net::OpenStack::Ceilometer->new(
    host     => '192.168.0.177',
    username => 'admin',
    password => '885d4b669cc04a1b',
);
isa_ok( $a, 'Net::OpenStack::Ceilometer' );

# Test that you successfully authed
isnt( $a->{access}, 0, 'Testing that we got an auth token.' );
is( $a->{access}{user}{username},
    $a->{username}, 'Sanity check - got the same username we sent' );

diag( "Testing Net::OpenStack::Ceilometer $Net::OpenStack::Ceilometer::VERSION, Perl $], $^X" );

done_testing();

