#!/usr/bin/perl

use strict;
use warnings;
use Digest::MD5 qw(md5);

my $myCnfLocation = shift;

if ($ENV{USER} ne 'root') {
	die "Run this script as root, yo."
}

# best guess as to proper IP addresses
my $ipInfo = `/sbin/ifconfig | grep 'inet addr' | grep -v 127.0.0`;

# only supporting 10.* and 192.* networks for now - sorry
my $ipAddr;
if ($ipInfo =~ /inet addr:((192|10)\..+?)\s/) {
	$ipAddr = $1;
} else {
	die "Unable to parse IP address from ifconfig output: $ipInfo";
}

print " + Got ipAddr = $ipAddr\n";

# read MySQL config
my $mysqlConfig = `cat $myCnfLocation | grep -v LEAVE_AT_DEFAULT_SETTING`;

# Generate 4-byte integer from IP address - put it into
# server_id in my.cnf
print " + Creating a server-id for MySQL\n";
my $md5Substr = substr( md5($ipAddr), 0, 4 );
my $serverID = unpack('L', $md5Substr);
$mysqlConfig =~ s/MYSQL_SERVER_ID/$serverID/gs;

# write out new my.cnf
open (OF, "> $myCnfLocation") || die "Couldn't write new $myCnfLocation";
print OF $mysqlConfig;
close (OF);

