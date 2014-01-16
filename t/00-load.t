#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

warn("\nThese tests probably won't pass for you. You'll need to force install until I can get the auth credentials moved into prompts. Patches welcome. Otherwise just edit the username and password in 00-load.t and try again.\n");

BEGIN {
    use_ok( 'Net::OpenStack::Ceilometer' ) || print "Bail out!\n";
}

my $a = Net::OpenStack::Ceilometer->new(
    host     => '192.168.0.177',
    username => 'admin',
    password => '885d4b669cc04a1b', # This should be in a config file, eh?
);
isa_ok( $a, 'Net::OpenStack::Ceilometer' );

# Test that you successfully authed
isnt( $a->{access}, 0, 'Testing that we got an auth token.' );
is( $a->{access}{user}{username},
    $a->{username}, 'Sanity check - got the same username we sent' );

my $resources = $a->resources();
isa_ok( $resources, 'ARRAY' );

my $resource = $resources->[0];
is( $resource->{source}, 'openstack' );

diag( "Testing Net::OpenStack::Ceilometer $Net::OpenStack::Ceilometer::VERSION, Perl $], $^X" );

done_testing();

