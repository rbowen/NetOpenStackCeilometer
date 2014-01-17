# NAME

Net::OpenStack::Ceilometer - Interface to OpenStack Ceilometer API

# VERSION

Version 0.01

# SYNOPSIS

Perl interface to Ceilometer API v2. Docs at
http://docs.openstack.org/developer/ceilometer/webapi/v2.html

    use Net::OpenStack::Ceilometer;

    my $ceilapi = Net::OpenStack::Ceilometer->new(
        host => 'localhost',
        port => '8777',
        url  => '/v2', # Leading slash, no trailing slash

        username => 'admin',
        password => 'password',
    );

    my @resources = $ceilapi->resources();
    my $resource  = $ceulapi->resource( $resource_id );

    ... and so on

    See http://docs.openstack.org/developer/ceilometer/webapi/v2.html
    for full API doc.

# EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

# SUBROUTINES/METHODS

## new

    my $ceilapi = Net::OpenStack::Ceilometer->new(
        host => 'localhost',
        port => '8777',
        url  => '/v2', # Leading slash, no trailing slash

        http => 'https', # If you want https
    );

## get\_auth\_token

FIXME
Note that this should probably call a higher-level Net::OpenStack
method, but those modules are still a mystery to me.

Gets auth token from Horizon

## resources

    my @resources = $ceilapi->resources();

## resource

    my $resource = $ceilapi->resource( $id );

## meters

Returns an arraref of all meters.

    my $meters = $ceilapi->meters();

## meter, meter\_by\_name, meter\_by\_id

    my $meter = $ceilapi->meter_by_id( $id );
    my $meter = $ceilapi->meter( $id );
    my $meter = $ceilapi->meter_by_name( $name );

## statistics

Computes the statistics of the samples in the time range given.

Parameters: 

    q (list(Query)) - Filter rules for the data to be returned.
    groupby (list(unicode)) - Fields for group by aggregation
    period (int) - Returned result will be an array of statistics for a period long of that number of seconds

## alarms

## call

Makes the actual HTTP requests to the API. Don't call this yourself.

# AUTHOR

Rich Bowen, `<rbow at cpan.org>`

# BUGS

For the moment, report bugs to rbow at cpan.org

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::OpenStack::Ceilometer



You can also look for information at:
https://github.com/rbowen/NetOpenStackCeilometer

# SOURCE

GitHub: https://github.com/rbowen/NetOpenStackCeilometer

# ACKNOWLEDGEMENTS

OpenStack Rocks

# LICENSE AND COPYRIGHT

Copyright 2014 Rich Bowen.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
