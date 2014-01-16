use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Net::OpenStack::Ceilometer',
    AUTHOR             => q{Rich Bowen <rbow@cpan.org>},
    VERSION_FROM       => 'lib/Net/OpenStack/Ceilometer.pm',
    ABSTRACT_FROM      => 'lib/Net/OpenStack/Ceilometer.pm',
    LICENSE            => 'Artistic_2_0',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'JSON::Parse'    => 0,
        'JSON'           => 0,
        'HTTP::Request'  => 0,
        'LWP::Simple'    => 0,
        'LWP::UserAgent' => 0,
        'Data::Dumper'   => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Net-OpenStack-Ceilometer-*' },
);
