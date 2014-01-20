package Net::OpenStack::Ceilometer;

use 5.006;
use strict;
use warnings FATAL => 'all';
use JSON;
use JSON::Parse;
use HTTP::Request;
use LWP::Simple qw(get);
use LWP::UserAgent;
use Data::Dumper;

=head1 NAME

Net::OpenStack::Ceilometer - Interface to OpenStack Ceilometer API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.12';


=head1 SYNOPSIS

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

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

    my $ceilapi = Net::OpenStack::Ceilometer->new(
        host => 'localhost',
        port => '8777',
        url  => '/v2', # Leading slash, no trailing slash

        http => 'https', # If you want https
    );

=cut

sub new {
    my ( $class, %parameters ) = @_;

    my $host = $parameters{host} || 'localhost';
    my $port = $parameters{port} || '8777';
    my $url  = $parameters{url}  || '/v2';
    $url =~ s!/$!!; # Strip trailing slash, just in case.

    my $username = $parameters{username} || 'admin';
    my $password = $parameters{password} || 'openstack';

    my $http = $parameters{http} || 'http';

    my $self = bless(
        {
            http => $http,
            host => $host,
            port => $port,
            url  => $url,

            username => $username,
            password => $password,
        }
    );

    # Fetch access token.
    $self->{ access } = $self->get_auth_token();

    return $self;
}

=head2 get_auth_token

FIXME
Note that this should probably call a higher-level Net::OpenStack
method, but those modules are still a mystery to me.

Gets auth token from Horizon

TODO: This generates a "Deprecated: v2 API is deprecated as of Icehouse
in favor of v3 API and may be removed in K" warning. So we need to
update this to the v3 api at some point soon.

=cut

sub get_auth_token {
    my $self = shift;

    my $url = 'http://' . $self->{host} . ':' . '5000/v2.0/tokens';
    my $ua  = LWP::UserAgent->new();

    my $auth_data = encode_json {
        'auth' => {
            "tenantName"          => "admin",
            "passwordCredentials" => {
                "username" => $self->{username},
                "password" => $self->{password},
            }
        }
    };

    my $req = HTTP::Request->new(POST => $url);
    $req->content_type('application/json');
    $req->header( 'accept' => 'application/json' );
    $req->content($auth_data);

    my $res = $ua->request($req);
    my $access;
    
    eval{ $access = JSON::Parse::json_to_perl( $res->decoded_content() ); };
    if ( $@ ) {
        warn "INVALID JSON RETURNED. PANIC.";
        return 0;
    } 

    # warn Dumper( $access );

    # Auth succeeded?
    if ( ref( $access->{access} )) {
        return $access->{access};
    } else {
        warn "Authentication failed. Check credentials.";
        return 0;
    }

}

=head2 resources

    my @resources = $ceilapi->resources();

=cut

sub resources {
    my $self = shift;

    my $resources = $self->call( '/resources' );
    $self->{resources} = $resources;

    foreach my $r ( @{ $self->{resources} } ) {
        $self->{resource_by_id}->{ $r->{resource_id} } = $r;
    }

    return ( $resources );
}

=head2 resource

    my $resource = $ceilapi->resource( $id );

=cut

sub resource {
    my $self = shift;
    my $id = shift;

    # populate resources
    $self->resources() unless ref( $self->{resources} );

    return $self->{resource_by_id}->{ $id } || 0;
}

=head2 meters

Returns an arraref of all meters.

    my $meters = $ceilapi->meters();

=cut

sub meters {
    my $self = shift;

    my $meters = $self->call( '/meters' );
    $self->{meters} = $meters;

    foreach my $r ( @{ $self->{meters} } ) {

        # By ID
        $r->{meter_id} =~ s/\n$//; # Has a \n on the end for some reason ...
        $self->{meter_by_id}->{ $r->{meter_id} } = $r;

        # By name
        $self->{meter_by_name}->{ $r->{name} } = [] unless ref( $self->{meter_by_name}->{ $r->{name} } );
        push( @{ $self->{meter_by_name}->{ $r->{name} } }, $r );
    }

    return ( $meters );
}

=head2 meter, meter_by_name, meter_by_id

    my $meter = $ceilapi->meter_by_id( $id );
    my $meter = $ceilapi->meter( $id );
    my $meter = $ceilapi->meter_by_name( $name );

Returns a hashref of details for the specified meter. Note that name is
not unique, so by_name returns an arrayref of one or more hashrefs.

Side effect: Populates the meters attribute of $self, if you haven't
already called meters() previously.

=cut

# Returns a list (ref) of all things with that name. Not sure how useful
# this is. Revisit. TODO
sub meter_by_name {
    my $self = shift;
    my $id   = shift;

    return $self->meter( $id, 'name' );
}

sub meter_by_id {
    my $self = shift;
    my $id   = shift;
    return $self->meter( $id, 'id' );
}

sub meter {
    my $self = shift;
    my $id   = shift;
    my $by   = shift || 'id';

    # populate meters
    $self->meters() unless ref( $self->{meters} );
    return $self->{ "meter_by_" . $by }->{$id} || 0;
}

=head2 statistics

Computes the statistics of the samples in the time range given.

Parameters: 

    q (list(Query)) - Filter rules for the data to be returned - see
    http://docs.openstack.org/developer/ceilometer/webapi/v2.html#samples-and-statistics
    for full docs on what these queries look like.
    groupby (list(unicode)) - Fields for group by aggregation
    period (int) - Returned result will be an array of statistics for a period long of that number of seconds

    my $s = $a->statistics(
        $meter_ID,
        [
            {
                'field' => 'resource_id',
                'op'    => 'eq',
                'value' => '64da755c-9120-4236-bee1-54acafe24980',
            }
        ]
    );

Yes, the docs suck. Please see the examples at the above URL until we
can doc this better.

Also, since there are numerous ways to request stats, please expect this
method to change to accomodate them all.

=cut

sub statistics {
    my $self       = shift;
    my $meter      = shift;
    my $parameters = shift;

    my $stats = $self->call( '/meters/' . $meter . '/statistics', $parameters );
    return $stats;
}

=head2 alarms

=cut

sub alarms {
    my $self = shift;
    my $alarms = $self->call( '/alarms' );
    $self->{alarms} = $alarms;

    return $alarms;
}

=head2 call

Makes the actual HTTP requests to the API. Don't call this yourself.
Also, don't count on the query stuff staying the way it is. 'Cause it
kind of sucks.

=cut

sub call {
    my $self = shift;
    my $method = shift;

    my $params = shift; # Query arguments - arrayref

    my $url =
        $self->{http} . '://' . $self->{host} . ':' . $self->{port}
      . $self->{url} . $method;

 
    my $ua  = LWP::UserAgent->new();
    my $token = $self->{access};
    $ua->default_header( 'X-Auth-Token' => $token->{token}{id} );
    $ua->default_header( 'User-Agent'   => 'perl/Net::OpenStack::Ceilometer' );
    $ua->default_header( 'Content-Type' => 'application/json' );
    $ua->default_header( 'Accept'       => 'application/json' );

    if ($params) {

        my @params;
        foreach my $a ( @$params ) { # order matters!!
            while ( my $q = shift @$a ) {
                push( @params, 'q.'.$q . '=' . shift @$a )
            }
        }
        $url .= '?' . join( '&', @params );
        warn "Fetching $url";
    }
    
    my $res = $ua->get( $url );

    if ( $res->is_success ) {
        return JSON::Parse::json_to_perl( $res->decoded_content() );
    } else {
        warn Dumper( $res->decoded_content() );
        return 0;
    }

}

=head1 AUTHOR

Rich Bowen, C<< <rbow at cpan.org> >>

=head1 BUGS

For the moment, report bugs to rbow at cpan.org

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::OpenStack::Ceilometer


You can also look for information at:
https://github.com/rbowen/NetOpenStackCeilometer

=head1 SOURCE

GitHub: https://github.com/rbowen/NetOpenStackCeilometer

=head1 ACKNOWLEDGEMENTS

OpenStack Rocks

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Rich Bowen.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Net::OpenStack::Ceilometer
