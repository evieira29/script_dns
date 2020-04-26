#!/bin/bash

#FUNCTION to BACKUP ZONE FILES

##FUNCTION - START
funcBkpZoneFiles () {
    cp /var/named/vieira.flz /var/named/vieira.flz.`date +%F_%R.bckp`
    cp /var/named/vieira.rlz /var/named/vieira.rlz.`date +%F_%R.bckp`
}
#FUNCTION - END

# Simple Input FUNCTION

## FUNCTION - START
funcInputInfo () {
read -p "Input client FQDN ; "  NAME
read -p "Input client IP Address; "        IPADDR
echo "HOSTNAME; $NAME "
echo "IP ADDRESS; $IPADDR "
echo "Will be Added to Zone Records"
read -p "Is This Correct? y/n " CONFIRM

#  - VARIABLES -
HNAME="`echo $NAME | cut -d "." -f 1` "
IP="`echo $IPADDR`"
IPEND="`echo $IPADDR | cut -d "." -f 4`"
NAMEDOT="`echo $NAME`."
}

## FUNCTION - END

# FUNCTION to EDIT .flz File

## FUNCTION - START
funcEditFlz () {
   echo "$HNAME     IN A     $IP" >> /var/named/vieira.flz
    ##sed command will replace the 3rd line in the file with the date  command (year,month,date,& minute format)
   sed -i "3c\ \t\t\t\t$(date +%y%m%d%M) ; serial" /var/named/vieira.flz
}
## FUNCTION - END

# FUNCTION To Edit .rlz File

## FUNCTION - START
funcEditRlz () {
   echo "$IPEND    IN PTR    $NAMEDOT" >> /var/named/vieira.rlz
    ##sed command will replace the 3rd line in the file with the date  command (year,month,date,& minute format)
   sed -i "3c\ \t\t\t\t$(date +%y%m%d%M) ; serial" /var/named/vieira.rlz
}
##FUNCTION - END

#FUNCTION to CHECK ZONE FILES & Reload the NAMED.SERVICE

##FUNCTION - START
funcCheckReload () {
   #Check Files for Errors
           named-checkconf -jz
      if [ "$?" = "0" ]; then
           rndc reload;
      else
            exit 1
      fi
}
##FUNCTION - END

#CHECK IF ZONE FILES EXIST
if [ -e /var/named/vieira.flz ] && [ -e /var/named/vieira.rlz ]; then
    funcInputInfo; #Call function to Hostname & IP
else
   echo "DNS Zone Records NOT Found"
   exit 1
fi

#IF STATEMENT to EDIT  ZONE FILES BASED On USER CONFIRMATION
if [ $CONFIRM = "y" ]; then
#   Call FUNCTIONS;
    funcBkpZoneFiles  #Backup files
    funcEditFlz       #Edit Flz
    funcEditRlz       #Edit Rlz
    funcCheckReload;  #Check and Reload Daemon
else
   echo "Bye"
   exit 1;
fi



