#!/bin/bash
mkdir -p /usr/app/boinc/locale
mkdir -p /usr/app/boinc/slots

if [ "$BALENA_DEVICE_TYPE" = "jetson-nano" ]; then
  echo 'Jetson Nano detected - enabling fan at 100%'
  echo 255 > /sys/devices/pwm-fan/target_pwm
fi

if [[ -z $ACCOUNT_KEY ]]; then
  echo 'Account key undefined - using balena key'
else
  echo 'Account key set'
  sed -i -e 's|<authenticator>[0-9a-z_]\{1,\}</authenticator>|<authenticator>'"$ACCOUNT_KEY"'</authenticator>|g' /usr/app/boinc/account_boinc.bakerlab.org_rosetta.xml
fi

totalmem=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)

if [ "$totalmem" -lt "1500000" ]; then
  echo "Less than 1.5GB RAM - running single concurrent task"
  sed -i -e 's|<max_ncpus_pct>[0-9a-z.]\{1,\}</max_ncpus_pct>|<max_ncpus_pct>25.000000</max_ncpus_pct>|g' /usr/app/boinc/global_prefs_override.xml
fi

exec boinc --dir /usr/app/boinc/ --allow_remote_gui_rpc