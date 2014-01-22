#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;
use Data::Dumper;

BEGIN {
    use_ok( 'Net::OpenStack::Ceilometer' ) || print "Bail out!\n";
}

my $a = Net::OpenStack::Ceilometer->new(
    host     => '192.168.0.177',
    username => 'admin',
    password => '6507ed71383b4544', # This should be in a config file, eh?
);
isa_ok( $a, 'Net::OpenStack::Ceilometer' );

my $meters = $a->meters();
isa_ok( $meters, 'ARRAY' );

my $meter = $meters->[0];
is( $meter->{source}, 'openstack' );

my $r2 = $a->meter_by_id( $meter->{meter_id} );

is( $r2->{meter_id}, $meter->{meter_id}, 'Object matches array element.');

# TODO - by name
# my $r = $a->meter_by_name( 'cpu_util' );
# warn Dumper( $r );

done_testing();

