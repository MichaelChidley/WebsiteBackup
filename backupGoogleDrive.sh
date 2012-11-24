#!/bin/bash

#Filename:      backGDrive.sh
#Created:       01/09/2012
#Author:        MJC
#Modified:      -
#
#       2012

#Setup the global variables
EMAIL_ADDR=""                                                   #Email address of the user
DIRECTORY_NAME=""                                               #The name of the folder where the site is store
BACKUP_DIR="/var/www/$DIRECTORY_NAME"                           #Append the name onto the end of the default root location for Ubuntu 12.04
GOOGLE_DRIVE_DIR="/home/USER/gDrive/"                           #Give the location of the sync folder to a variable
WEBSITE_DIR="WebsiteBackups/"                                   #Sub directory within google drive, if applicable
CRON_JOB_LOC="/etc/cron.daily/"                                 #Location of where this currect script is stored
USAGE="Usage: $0 BACKUP_DIRECTORY EMAIL_ADDRESS"
UNIQ_DATE=`date +%d-%m-%y`                                      #Unique date, to be appended to the file
RAND_STRING=`tr -dc "[:alpha:]" < /dev/urandom | head -c 14`    #The linux command to create a random string using upper and lower case alphabet

#Check if the backup directory exists
if [ ! -d "$BACKUP_DIR" ]
then
	#If it is not found, oput an error with help info
	echo "Backup Directory Does Not Exist!"
	echo $USAGE
	exit
fi


#Compress the directory to a tar format
tar -cvf $BACKUP_DIR.$UNIQ_DATE.tar $BACKUP_DIR/


###################     Added unique encrpytion for safer storage       #####################
#Encrpy the file with a randomly generated string
gpg --yes --passphrase $RAND_STRING -c $BACKUP_DIR.$UNIQ_DATE.tar
#Once encrypted, remove the orginal file (unencrypted)
rm $BACKUP_DIR.$UNIQ_DATE.tar


#Email the specified email address with the details of the randomly generated encryption key, as this is a small email it will always send
echo "Encryption Key Generated For $DIRECTORY_NAME.$UNIQ_DATE.gpg 

$RAND_STRING " | mutt -s "Encryption Key" -- $EMAIL_ADDR


####################    Modified To Upload To Google Drive Instead      #####################

#Check whether the file already exists in the google drive sync, used for testing purposes as it wont get reuploaded
if [ -e "$GOOGLE_DRIVE_DIR$WEBSITE_DIR$DIRECTORY_NAME.$UNIQ_DATE.tar.gpg" ]; then
        rm $GOOGLE_DRIVE_DIR$WEBSITE_DIR$DIRECTORY_NAME.$UNIQ_DATE.tar.gpg
        cd $GOOGLE_DRIVE_DIR && grive && cd $CRON_JOB_LOC 
fi

#Move the file to the google drive sync directory
mv $BACKUP_DIR.$UNIQ_DATE.tar.gpg $GOOGLE_DRIVE_DIR$WEBSITE_DIR

#Change directory to the google drive sync folder, and run the command to sync!
cd $GOOGLE_DRIVE_DIR && grive 