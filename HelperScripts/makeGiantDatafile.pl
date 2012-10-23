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

use warnings;
use strict;

my $numUsers = shift || doUsage();
my $numPostings = shift || doUsage();
my $estimateTitleWords = 8;
my $fewestWords = 60;
my $mostWords = 200;

my @dictWords = split (/\n/, `cat wordList.txt /usr/share/dict/words`);

# make the table if it doesn't exist
print 'CREATE TABLE if not exists `postings` (' . "\n";
print '  `user_id` int unsigned NOT NULL,' . "\n";
print '  `post_id` int unsigned NOT NULL,' . "\n";
print '  `title` varchar(64) NOT NULL,' . "\n";
print '  `words` varchar(2048) NOT NULL,' . "\n";
print '  PRIMARY KEY (`user_id`, `post_id`)' . "\n";
print ') ENGINE=InnoDB DEFAULT CHARSET=utf8' . "\n";
print ";\n";

my $i;
my $j;
my $k;
my $title = "";
my $words = "";
for ($i=1; $i <= $numUsers; $i++) {
	for ($j=1; $j <= $numPostings; $j++) {
		$title = "";
		for ($k=0; $k < $estimateTitleWords - 4 + int (rand (8)); $k++) {
			$title .= " " . oneDictWord();
		}
		$words = "";
		for ($k=0; $k < $fewestWords + int (rand ($mostWords)); $k++) {
			$words .= " " . oneDictWord();
			if (int (rand 8) == 0) { $words .= "."; }
		}

		# escape quotes for mysql
		$title =~ s/'/''/g;
		$words =~ s/'/''/g;
		print "insert into postings values ($i, $j, '$title',\n   '$words');\n";
	}
}

exit 0;

# return a random work from the dictionary
sub oneDictWord {
	return $dictWords[int (rand @dictWords)];
}

# print usage and exit
sub doUsage {
	print "usage: $0 numUsersToInsert numPostingsPerUser\n";
	exit 255;
}
