#!/usr/bin/perl

use warnings;
use strict;
use POSIX qw/strftime/;

#check for existence of done_copying file
#compose filename out of timestamp
#create ./archive if it doesnt exist
#create compressed tarball
#drop tarball into ./archive

my @paths = </data/*>;


foreach my $path (@paths){
	next if($path eq '/data/lost+found');

	if(-e "$path/backup/done_copying"){
		print "ready to archive $path\n";

#compose filename out of timestamp
		my $date = strftime "%y%m%d", localtime;
		my @host = split (/\//,$path);
		my $filename = "$date-archive-$host[-1].tar.gz";

#create ./archive if it doesnt exist
		system("mkdir -p $path/archive");

#create compressed tarball
#drop tarball into ./archive
		system("tar cvfz $path/archive/$filename $path/backup");

	}else{
		print "not ready to archive $path\n";
	}

}
