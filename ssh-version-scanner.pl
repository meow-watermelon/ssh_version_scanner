#!/usr/bin/env perl

use warnings;
use strict;

use Data::Dumper;
use Getopt::Long;
use IO::Socket::IP qw(:DEFAULT :crlf);

$/ = CRLF;
my ($host, $port, $timeout) = (undef, 22, 5);

GetOptions(
    "host=s" => \$host,
    "port=i" => \$port,
    "timeout=i" => \$timeout,
);

sub usage {
    my $usage = <<"USAGE";
$0 --host <hostname> [--port <SSH server port>] [--timeout <connection timeout>]

DEFAULT SSH SERVER PORT: 22
DEFAULT CONNECTION TIMEOUT: 5 secs
USAGE

    print $usage;
}

if (!defined($host)) {
    usage();
    exit 1;
}

my $sock = IO::Socket::IP->new(
    PeerHost => $host,
    PeerPort => $port,
    Type => SOCK_STREAM,
    Sockopts => [
        [SOL_SOCKET, SO_REUSEADDR, 1],
        [SOL_SOCKET, SO_LINGER, pack("II",1,0)],
    ],
    Timeout => $timeout,
) or die "$host - $port - ERROR - $!\n";

chomp(my $ssh_version_string = $sock->getline);

print "$host - $port - $ssh_version_string\n";

close $sock;
