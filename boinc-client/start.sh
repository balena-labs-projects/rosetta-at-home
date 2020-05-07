#!/bin/bash
mkdir -p /usr/app/boinc/locale
mkdir -p /usr/app/boinc/slots

prefs_file_path='global_prefs_override.xml'
cfg_ram_max_busy_xml_key='ram_max_used_busy_pct'
cfg_ram_max_idle_xml_key='ram_max_used_idle_pct'
threshold_ram_settings_pct=95

. start-utils.sh

cd /usr/app/boinc

if [ "$BALENA_DEVICE_TYPE" = "jetson-nano" ]; then
  echo 'Jetson Nano detected - enabling fan at 100%'
  echo 255 > /sys/devices/pwm-fan/target_pwm
fi

if [[ -z $ACCOUNT_KEY ]]; then
  echo 'Account key undefined - using balena key'
else
  echo 'Account key set'
  sed -i -e 's|<authenticator>[0-9a-z_]\{1,\}</authenticator>|<authenticator>'"$ACCOUNT_KEY"'</authenticator>|g' account_boinc.bakerlab.org_rosetta.xml
fi

if [[ -z $SKIP_BOINC_MEM_SETTINGS_CHECK ]]; then
  validate_ram_settings
fi

totalmem=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)

if [[ -z $SKIP_BOINC_CPU_SETTINGS_CHECK && "$totalmem" -lt "2500000" ]]; then
  echo "Less than 2.5GB RAM - running single concurrent task"
  update_float_xml_val_with_int max_ncpus_pct 25 "$prefs_file_path"
elif [[ -z $SKIP_BOINC_CPU_SETTINGS_CHECK && "$BALENA_DEVICE_TYPE" = "raspberrypi4-64" ]]; then
  echo "Raspberry Pi 4 4GB - running 3 concurrent tasks"
  update_float_xml_val_with_int max_ncpus_pct 75 "$prefs_file_path"
fi

exec boinc --dir /usr/app/boinc/ --allow_remote_gui_rpc
