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
    password => '6507ed71383b4544', # This should be in a config file, eh?
);
isa_ok( $a, 'Net::OpenStack::Ceilometer' );

my $resources = $a->resources();
isa_ok( $resources, 'ARRAY' );

my $resource = $resources->[0];
is( $resource->{source}, 'openstack' );

my $r = $a->resource( $resource->{resource_id} );
is( $r->{resource_id}, $resource->{resource_id}, 'Object matches array element.');

done_testing();


