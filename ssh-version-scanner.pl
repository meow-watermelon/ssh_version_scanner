#!/usr/bin/env perl

use warnings;
use strict;

use Data::Dumper;
use Getopt::Long;
use IO::Socket::IP qw(:DEFAULT :crlf);

$/ = CRLF;
my ($host, $port, $timeout) = (undef, 22, 5);
my $ssh_version_string = undef;

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

# set up 5 secs timeout timer: client timeouts if no response from the SSH server after TCP handshake is done
eval {
    local $SIG{ALRM} = sub { die "timeout\n" };
    alarm(5);
    chomp($ssh_version_string = $sock->getline);
};

alarm(0);

if ($@ =~ /timeout/) {
    die "$host - $port - ERROR - Client Timeout\n";
} else {
    print "$host - $port - $ssh_version_string\n";
}

close $sock;
