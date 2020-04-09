#! /bin/bash

# start gotty with boinctui
/usr/app/gotty -w -p 80 boinctui&

#switch to tty2, clear screen and display boinctui 
chvt 2
printf "\033c" > /dev/tty2
boinctui 2> /dev/null > /dev/tty2
