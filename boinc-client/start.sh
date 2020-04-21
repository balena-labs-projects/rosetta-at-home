#!/bin/bash
mkdir -p /usr/app/boinc/locale
mkdir -p /usr/app/boinc/slots

if [[ -z $ACCOUNT_KEY ]]; then
  echo 'Account key undefined - using balena key'
else
  echo 'Account key set'
  sed -i -e 's|<authenticator>[0-9a-z_]\{1,\}</authenticator>|<authenticator>'"$ACCOUNT_KEY"'</authenticator>|g' /usr/app/account_boinc.rosetta.bakerlab.org.xml
fi

totalmem=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)

if [ "$totalmem" -lt "2500000" ]; then
  echo "Less than 2.5GB RAM - running single concurrent task"
  exec boinc --dir /usr/app/boinc/ --allow_remote_gui_rpc --fetch_minimal_work
else
  exec boinc --dir /usr/app/boinc/ --allow_remote_gui_rpc
fi
