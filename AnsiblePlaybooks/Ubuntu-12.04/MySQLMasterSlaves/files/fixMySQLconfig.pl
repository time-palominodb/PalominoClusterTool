#!/usr/bin/perl

#   Copyright 2012 Tim Ellis
#   CTO: PalominoDB
#   The Palomino Cluster Tool
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

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

