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

# usage help if they don't do it right
my $usage = "usage: $0 <masterHost>[:<masterPort>] <replUser> <replPassword> [<logFile> <logPos>]\n";
$usage .= "example: $0 10.1.1.1:3306 repl PaSsWoRd log-000001.bin 4\n";

my $masterHost = shift || die $usage;
my $replUser = shift || die $usage;
my $replPassword = shift || die $usage;

my $masterPort = 3306;
if ($masterHost =~ /^(.+?):(\d+)$/) {
	$masterHost = $1;
	$masterPort = $2;
}

my $logFile = shift;
my $logPos = shift;

my $changeMasterSQL = "slave stop;
change master to
  master_host = '$masterHost',
  master_port = $masterPort,
  master_user = '$replUser',
  master_password = '$replPassword'";

if ($logFile) { $changeMasterSQL .= ",\n  master_log_file = '$logFile'"; }
if ($logPos) { $changeMasterSQL .= ",\n  master_log_pos = $logPos"; }

# close out the statement, restart the slave
$changeMasterSQL .= "
;
slave start;
";

print $changeMasterSQL;

