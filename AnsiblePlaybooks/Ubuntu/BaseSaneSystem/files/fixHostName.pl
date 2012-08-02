#!/usr/bin/perl

use strict;
use warnings;

if ($ENV{USER} ne 'root') {
	die "Run this script as root, yo."
}

my $ipInfo = `/sbin/ifconfig`;
my $ipAddr = 'UNKNOWN';

if ($ipInfo =~ /inet addr:((192|10)\..+?)\s/) {
	$ipAddr = $1;
} else {
	die "Unable to parse IP address from ifconfig output: $ipInfo";
}

print " + Got ipAddr = $ipAddr\n";

# hostname gets to be vb+final octet
my $hostName = 'UNKNOWN';
if ($ipAddr =~ /\.(\d+)$/) {
	$hostName = "vb$1";
} else {
	die "Unable to parse final octet from $ipAddr";
}

print " + Set hostname to $hostName\n";

# get /etc/hosts and doctor it up right
my $etcHosts = `cat /etc/hosts`;
$etcHosts =~ s/vb01/$hostName/gs;

# write hostname info into proper files
print " + Writing /etc/hosts\n";
open (OF, "> /etc/hosts") || die "Can't write /etc/hosts";
print OF $etcHosts;
close (OF);

print " + Writing /etc/hostname\n";
open (OF, "> /etc/hostname") || die "Can't write /etc/hostname";
print OF $hostName . "\n";
close (OF);

print " + Telling config management tool I've run\n";
open (OF, "> $ENV{HOME}/hostNameFixed");
print OF "$0 run from $ENV{PWD} fixed the hostname\n";
close (OF);

