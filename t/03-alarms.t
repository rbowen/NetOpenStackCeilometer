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

my $alarms = $a->alarms();
isa_ok( $alarms, 'ARRAY' );

done_testing();

