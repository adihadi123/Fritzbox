#!/usr/bin/bash
#
# Author:       Roy Schlegel
# E-Mail:       royschlegel@web.de
# Version:      0.01
# Last Updated: 12.02.2021
#
# Description:
# This script is for a device in your network to proof the connection to 8.8.8.8 (www.google.de).
# If the ping performed successfully the script is over.
# If the ping failed the script will reboot the Fritzbox to get a new connection and hopefully internet access again.

# Usage:
# - Take the script
# - Enter your login credentials for the Fritzbox in the section below
# - Make the file executable chmod + x pathTofile/reboot.sh
# - Now is possible to start the script manually, cronjobs or whatever you want
#


### ENTER HERE YOUR CREDENTIALS ###

USERNAME="user"
PASSWORD="password"
BOXURL="http://fritz.box"                               #ip is fine too
SERVERIP="8.8.8.8"


## Dont change things behind this line

for ((i=1;i<=3;i++))
do                                                           #ping request for google.de
  if ping -c3 ${SERVERIP}; then (                              #everything is fine
  echo "Internet connection established
      > All Okay"
      echo "`date`"
break
) else (
                                                              #if no answer then reboot
echo "No connection to Internet or Server offline!!
      > The Router is going to be reboot now!"

CHALLENGE=$(curl -s ${BOXURL}/login.lua | grep "^g_challenge" | awk -F '"' '{ print $2 }')
MD5=$(echo -n ${CHALLENGE}"-"${PASSWORD} | iconv -f ISO8859-1 -t UTF-16LE | md5sum -b | awk '{print substr($0,1,32)}')
RESPONSE="${CHALLENGE}-${MD5}"
SID=$(curl -i -s -k -d 'response='${RESPONSE} -d 'page=' -d "username=${USERNAME}" "${BOXURL}/login.lua" | grep "Location:" | grep -Poi 'sid=[a-f\d]+' | cut -d '=' -f2)

# Box rebooten
echo 'Reboot in progress ... please allow up to 2 minutes for the box to come up!'
curl -s "${BOXURL}/reboot.lua?sid=${SID}&extern_reboot=1&ajax=1" >/dev/null                                                       #
)
#EOF
