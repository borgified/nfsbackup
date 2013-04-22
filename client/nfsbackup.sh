#!/usr/bin/env sh

DIRLIST=$1

HOSTNAME=`/usr/bin/hostname`
MOUNT_SRC="usrc-nfsbackup:/data"
MOUNT_PATH="/nfs/usrc-nfsbackup"
BACKUP_PATH="$MOUNT_PATH/$HOSTNAME/backup"
BACKUP_SLASH="$BACKUP_PATH/_slash_"

RM="/usr/bin/rm"
TOUCH="/usr/bin/touch"
CP="/usr/bin/cp -p -r"
MOUNT="/usr/sbin/mount"
UMOUNT="/usr/sbin/umount"
DATE=`/usr/bin/date`
MKDIR="/usr/bin/mkdir -p"
DIRNAME="/usr/bin/dirname"
GREP="/usr/bin/grep"
#SunOS usamsu04 5.6 Generic_105181-29 sun4u sparc SUNW,Ultra-60
#SunOS scorpion 5.10 Generic_139556-08 i86pc i386 i86pc
#GREP="/usr/xpg4/bin/grep"

if [ $# -eq 0 ]; then
	echo "$DATE Need a dirlist file as argument. Exiting."
	exit	
fi

if  [ ! -f $1 ]; then
	echo "$DATE $1 is not a regular file or doesn't exist. Exiting."
	exit
fi

ISMOUNTED=`$MOUNT | $GREP "$MOUNT_PATH"`
if [ -z "$ISMOUNTED" ] ; then
	echo "$DATE Mounting $MOUNT_SRC to $MOUNT_PATH"
	$MOUNT $MOUNT_SRC $MOUNT_PATH
fi

ISMOUNTED=`$MOUNT | $GREP "$MOUNT_PATH"`
if [ -z "$ISMOUNTED" ] ; then
        echo "$DATE Previous mount attempt was unsuccessful, aborting"
        exit 1
fi



$RM $BACKUP_PATH/done_copying

echo "$DATE Backing up files to $BACKUP_PATH"
cat $DIRLIST | while read LINE
do
	if [ "x$LINE" = "x" ] ; then
		continue
	fi

        echo "$LINE" | $GREP -q "^#"
        if [ $? -eq 0 ] ; then
                continue
        fi

        if  [ ! -d $LINE ] ; then
                echo "$DATE $LINE is not a directory, skipping"
                continue
        fi

	echo "$LINE" | $GREP -q "^/nfs"
	if [ $? -eq 0 ] ; then
		echo "$DATE Not going to backup the backup files '$LINE', skipping"
		continue
	fi

        echo "$LINE" | $GREP -q "^/$"
        if [ $? -eq 0 ] ; then
                echo "$DATE Refusing to back up '/' since that includes '/nfs', skipping"
                continue
        fi

	echo "$DATE Copying $LINE to ${BACKUP_SLASH}${LINE}"
	if [ ! -d ${BACKUP_SLASH}${LINE} ]; then
		$MKDIR ${BACKUP_SLASH}${LINE}
	fi

	DEST=`$DIRNAME ${BACKUP_SLASH}${LINE}`
	$CP $LINE $DEST
done

$TOUCH $BACKUP_PATH/done_copying
echo "$DATE Unmounting $MOUNT_PATH"
`$UMOUNT $MOUNT_PATH`
echo "$DATE All done."
