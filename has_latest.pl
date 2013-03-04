#!/usr/bin/perl

my $email='email@domain.com';

use warnings;
use strict;
use POSIX qw/strftime/;
use Sys::Hostname;

#check timestamps of files
#compare with todays date
#email if today.timestamp - file.timestamp > 24 hrs

my @paths = </data/*>;


foreach my $path (@paths){
	next if($path eq '/data/lost+found');

	if(-e "$path/backup/done_copying"){
		print "ready to check $path\n";

		my $ts = (stat("$path/backup/done_copying"))[9];

		my $secs_since_last_copy = time-$ts;
		my $secs_in_a_day = 60*60*24;

		if($secs_since_last_copy > $secs_in_a_day){
			&send_alert("files in $path are over a day old");
		}

	}else{
		print "not ready to check $path\n";
		&send_alert("did not copy because $path/backup/done_copying does not exist");
	}
}

sub send_alert {

	open(MAIL, "|/usr/sbin/sendmail -t");
	my $host=hostname;
	my $from=$0.'@'.$host;
	my $subject='ALERT: '.$host;

	my $error_message = shift @_;

	print MAIL "To: $email\n";
	print MAIL "From: $from\n";
	print MAIL "Subject: $subject\n\n";

	print MAIL "-------------------------------------------\n";
	print MAIL "$error_message\n";
	print MAIL "-------------------------------------------\n";

	close(MAIL);


}
