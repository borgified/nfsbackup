#!/usr/bin/env perl

#sort contents of /data/*/archive/*.tar.gz by filename
#since the filename has timestamp, reverse sort will
#allow us to delete files that are older than 5 backups


use strict;
use warnings;

my @paths = </data/*>;

foreach my $path (@paths){
	next if($path eq '/data/lost+found');

	if(-e "$path/archive"){
#		print "ready to clean up $path/archive\n";
		my @archives = <$path/archive/*.tar.gz>;
		my $number_of_archives=@archives;
		my @rsorted = reverse sort @archives;
		if($number_of_archives > 5){
#			print "@rsorted[5..$#rsorted]\n";
			# $#rsorted is the highest index of @rsorted
			unlink @rsorted[5..$#rsorted];
		}
	}
}

