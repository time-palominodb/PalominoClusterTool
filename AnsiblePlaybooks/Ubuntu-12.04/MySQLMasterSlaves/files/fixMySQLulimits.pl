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

# pam doesn't seem to work without more rejiggering...
# so even though we modify limits.conf...
my $ulimitsFileLocation = shift || die "Usage: $0 <limits.confLocation> <pam.d/common-sessionLocation>";
my $ulimitsFile = `cat $ulimitsFileLocation` || die "Couldn't read $ulimitsFileLocation";

print " - Modifying $ulimitsFileLocation...\n";

my $desiredMySQLlimits = 
	  "# BEGIN PalominoClusterTool MySQL ulimits\n"
	. "mysql              soft    nofile      22000\n"
	. "mysql              hard    nofile      768727\n"
	. "mysql              soft    nproc       32000\n"
	. "mysql              hard    nproc       63000\n"
	. "# END PalominoClusterTool MySQL ulimits\n";

# change previous settings if they exist
$ulimitsFile =~ s/(\n+)# BEGIN PalominoClusterTool MySQL ulimits(.+?)# END PalominoClusterTool MySQL ulimits(\n+)/\n/gs;
$ulimitsFile .= "\n\n$desiredMySQLlimits";

open (OF, "> $ulimitsFileLocation") || die "Can't open $ulimitsFileLocation for writing";
print OF $ulimitsFile;
close (OF);

# ...we also modify pamfile
my $pamLocation = shift || die "Usage: $0 <limits.confLocation> <pam.d/common-sessionLocation>";
my $pamFile = `cat $pamLocation | grep -v pam_limits.so` || die "Couldn't read $pamLocation";

print " - Modifying $pamLocation...\n";

$pamFile .= "\nsession required pam_limits.so\n";

open (OF, "> $pamLocation") || die "Can't open $pamLocation for writing";
print OF $pamFile;
close (OF);

