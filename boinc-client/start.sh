#!/bin/bash
if [[ -z $ACCOUNT_KEY ]]; then
  echo 'Account key undefined - using balena key'
else
  echo 'Account key set'
  sed -i -e 's|<authenticator>[0-9a-z_]\{1,\}</authenticator>|<authenticator>'"$ACCOUNT_KEY"'</authenticator>|g' /usr/app/account_boinc.rosetta.bakerlab.org.xml
fi

exec boinc --allow_remote_gui_rpc