#!/usr/bin/perl

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
print '  PRIMARY KEY (`user_id`)' . "\n";
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
