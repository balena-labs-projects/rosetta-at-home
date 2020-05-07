#!/bin/bash
mkdir -p /usr/app/boinc/locale
mkdir -p /usr/app/boinc/slots

f4c_account_key='2085224_4b01976e2d7527db54825c9f27acad26'
account_template_file_path='/usr/app/account_boinc.bakerlab.org_rosetta.xml.template'
account_file_path='account_boinc.bakerlab.org_rosetta.xml'
cc_config_file='cc_config.xml'
rpc_config_file='gui_rpc_auth.cfg'
prefs_file_path='global_prefs_override.xml'
cfg_ram_max_busy_xml_key='ram_max_used_busy_pct'
cfg_ram_max_idle_xml_key='ram_max_used_idle_pct'
threshold_ram_settings_pct=95

. start-utils.sh

cd /usr/app/boinc

cp "/usr/app/$prefs_file_path" .
cp "/usr/app/$cc_config_file" .
cp "/usr/app/$rpc_config_file" .

if [ ! -f "$account_file_path" ]; then
    echo "Account file not found - creating from template"
    cp "$account_template_file_path" "$account_file_path"
fi

if [ "$BALENA_DEVICE_TYPE" = "jetson-nano" ]; then
  echo 'Jetson Nano detected - enabling fan at 100%'
  echo 255 > /sys/devices/pwm-fan/target_pwm
fi

check_account_key

if [[ -z $SKIP_BOINC_MEM_SETTINGS_CHECK ]]; then
  validate_ram_settings
fi

totalmem=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)

if [[ -z $SKIP_BOINC_CPU_SETTINGS_CHECK && "$totalmem" -lt "2500000" ]]; then
  echo "Less than 2.5GB RAM - running single concurrent task"
  update_float_xml_val_with_int max_ncpus_pct 25 "$prefs_file_path"
fi

exec boinc --dir /usr/app/boinc/ --allow_remote_gui_rpc
