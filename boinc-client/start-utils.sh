get_int_xml_val() {
  local xml_val=$(xml_grep --text_only "$1" "$2")
  local xml_int_val=$(awk "BEGIN {print int($xml_val)}")
  echo $xml_int_val
}

update_float_xml_val_with_int() {
  sed -i -e "s|<$1>[0-9a-z.]\{1,\}</$1>|<$1>$2.000000</$1>|g" "$3"
}

validate_ram_settings() {
  local cfg_ram_max_busy=$(get_int_xml_val "$cfg_ram_max_busy_xml_key" "$prefs_file_path")
  local cfg_ram_max_idle=$(get_int_xml_val "$cfg_ram_max_busy_xml_key" "$prefs_file_path")

  echo "Validating boinc RAM settings"

  if [[ ! -z $cfg_ram_max_busy && $cfg_ram_max_busy -gt $threshold_ram_settings_pct ]]; then
    echo "  max RAM when busy (${cfg_ram_max_busy}%) too high - setting to ${threshold_ram_settings_pct}%"
    update_float_xml_val_with_int "$cfg_ram_max_busy_xml_key" "$threshold_ram_settings_pct" "$prefs_file_path"
  fi

  if [[ ! -z $cfg_ram_max_idle && $cfg_ram_max_idle -gt $threshold_ram_settings_pct ]]; then
    echo "  max RAM when idle (${cfg_ram_max_idle}%) too high - setting to ${threshold_ram_settings_pct}%"
    update_float_xml_val_with_int "$cfg_ram_max_idle_xml_key" "$threshold_ram_settings_pct" "$prefs_file_path"
  fi
}

check_account_key() {
  echo "Checking account key"

  # we check to make sure the account key in account_boinc.bakerlab.org_rosetta is set correctly
  # if the desired account key is different to the one we currently have, we remove all existing XML config and change it
  local current_key=$(xml_grep --text_only "authenticator" "$account_file_path" | awk "NR==1{print $1}")

  if [[ -z $ACCOUNT_KEY ]]; then
    echo 'User account key undefined - using Fold for Covid key'
    local new_key="$f4c_account_key"
  else
    echo 'User account key set'
    local new_key="$ACCOUNT_KEY"
  fi

  # is the key changing?
  if [[ ! "$current_key" = "$new_key" ]]; then
    echo 'Account key change detected - purging'
    rm -rf /usr/app/boinc/*

    # set the new key with a fresh version of template file
    cp "$account_template_file_path" "$account_file_path"
    sed -i -e 's|<authenticator>[0-9a-z_]\{1,\}</authenticator>|<authenticator>'"$new_key"'</authenticator>|g' "$account_file_path"

    # restore other xml files
    cp "/usr/app/$prefs_file_path" .
    cp "/usr/app/$cc_config_file" .
    cp "/usr/app/$rpc_config_file" .
  fi
}