#!/bin/bash


#Apply the two arguments to their own variable
BACKUP_DIR="/var/www/"$1
EMAIL_ADDR=$2
USAGE="Usage: $0 BACKUP_DIRECTORY EMAIL_ADDRESS"
HOSTNAME=hostname

#Check whether the arguments have been included
if [ "$#" -eq 1 ]
then
	#If there not set, exit the script with help info
	echo "Invalid Arguments, Are They All Set?"
	echo $USAGE
	exit
fi


#Check if the backup directory exists
if [ ! -d "$BACKUP_DIR" ]
then
	#If it is not found, output an error with help info
	echo "Backup Directory Does Not Exist!"
	echo $USAGE
	exit
fi


#If everything is correct, compress the backup folder, email then delete
tar -cvf $BACKUP_DIR.tar $BACKUP_DIR/

#Send the email with a simple body text
echo "Backup from $HOSTNAME" | mutt -s "Backup" -a $BACKUP_DIR.tar -- $EMAIL_ADDR

#Now the backup file is no longer needed, we can delete it
rm $BACKUP_DIR.tar 