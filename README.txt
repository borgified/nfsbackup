just some simple scripts for managing nfs based backups, typically
for boxes too old to install the proper backup agent.

basic concept as follows:

create a VM (hostname: nfsbackup), export /data to * (everyone)

suppose hostname of the machine we want to backup = oldhost
mount nfsbackup:/data on oldhost
make modifications on /etc/fstab to keep it mounted after reboot

on the VM, create directory for oldhost: /data/oldhost/backup

on oldhost, write a script to drop files into: /data/oldhost/backup
run it once a day using cron

back on the VM:
run on cron:
0 12 * * 1-5 /root/scripts/archiver.pl
0 11 * * 1-5 /root/scripts/has_latest.pl
0 10 * * 1-5 /root/scripts/janitor.pl

archiver.pl will create directory /data/*/archive for each "host" 
and drop gzipped tarball of the contents of /data/*/backup.

in our example, it would create
/data/oldhost/archive/YYMMDD-archive-oldhost.tar.gz

where YYMMDD is the date when the backup occured.

has_latest.pl makes sure that every host that is suppose to drop a
file for backup, does so. checks by looking at the timestamps of the
files under /data/*/backup
sends alert email if files found are "too old" ie. missed a backup

janitor.pl cleans up /data/*/archive directories by keeping the latest
five backups and deleting anything older than that.


additional notes:
archiver.pl checks for a 0 byte file "done_copying" in /data/*/backup
to be sure that we have the complete file before we start archiving.
obviously, your script that copies the files into /data/*/backup daily
should remove "done_copying" at the start of the process and put it
back when it is done copying.

the VM which now contains the backup data from multiple hosts is
itself backed up through a different method, like Veeam.
