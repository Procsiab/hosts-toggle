#!/bin/bash

# author: Lorenzo Prosseda
# license: GNU

_HOSTS_FILE="/etc/hosts"
_SETTINGS_FILE="settings.txt"
_SCRIPT_SWITCH=""
_SCRIPT_YES=0
_SCRIPT_BACKUP=1
_SCRIPT_VERSION=1.0

# Check if the script was run by user root; exit otherwise
function _fn_check_root {
	if [ "$EUID" -ne 0 ]
		then echo "[ERR]: Please run this script with 'sudo'!"
		exit
	fi
}

# Back up current hosts file, if any
function _fn_backup {
	if [ -f "$_HOSTS_FILE" ]
	then
		if [ $_SCRIPT_BACKUP -eq 1 ]
		then
			_backup_name="$_HOSTS_FILE.bak-`date +%s%N | cut -b1-13`"
			cp "$_HOSTS_FILE" "$_backup_name"
			echo "[INFO]: Created backup file: $_backup_name"
		else
			echo "[INFO]: Backup skipped"
		fi
	else
		echo "[WARN]: No hosts file found, so no back up was created!"
		touch "$_HOSTS_FILE"
		echo "[INFO]: Created file hosts"
	fi
}

# Write the IP/Hostnames in the hosts file
function _fn_write_hosts {
	# Check if file has the pattern used by this script
	( (cat "$_HOSTS_FILE" | grep "# Hosts-Toggle") && (cat "$_HOSTS_FILE" | grep "# Toggle-Hosts") ) 1> /dev/null 
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "# Hosts-Toggle" | (tee -a "$_HOSTS_FILE" 1> /dev/null)
		echo "# Toggle-Hosts" | (tee -a "$_HOSTS_FILE" 1> /dev/null)
		echo "[INFO]: Wrote patterns to file hosts"
	fi
	# Clear pre-existing script-added hosts
	sed -i.bak '/# Hosts-Toggle/,/# Toggle-Hosts/{//!d}' "$_HOSTS_FILE"
	if [[ $_SCRIPT_SWITCH = "on"  ]]
	then
		# Insert hosts from settings file between the patterns
		sed -i.bak '/# Hosts-Toggle/r settings.txt' "$_HOSTS_FILE"
		echo "[INFO]: Added custom hosts to file"
	elif [[ $_SCRIPT_SWITCH = "off"  ]]
	then
		echo "[INFO]: Removed custom hosts from file"
	else
		echo "[ERR]: Wrong usage; you may call this script as hosts-toggle -s on|off (-y) (-f settings.txt)"
	fi
}

# Guide the user throughout the script, prompt for file problems
function _fn_main {
	_fn_check_root
	echo "*********** HOSTS TOGGLE ***********"
	echo "The hosts defined into settings.txt"
	echo "file will be written to the hosts"

	if [[ $_SCRIPT_YES -ne 1 ]]
	then
		read -p "Are you sure? [y/N]" -n 1 -r
	else
		REPLY="y"
	fi
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		_fn_backup
		_fn_write_hosts	
		echo
		echo "******** HOSTS FILE UPDATED ********"
		echo "You can find a backup file in the"
		echo "same folder, named hosts.bak-ETA"
	fi
}

# Parse command line arguments
while [[ "$#" > 0 ]]
do
	case $1 in
 		-y)
			_SCRIPT_YES=1;;
 		--no-bak) 
			_SCRIPT_BACKUP=0;;
		-h|--help)
			echo "Usage: hosts-toggle (on|off) (-y) (--no-bak) (-s /path/to/settings.txt)"
			exit 0;;
		-v|--version)
			echo "Script version: $_SCRIPT_VERSION"
			exit 0;;
 		on|off) 
			_SCRIPT_SWITCH=$1;;
		-s|--settings)
			_SETTINGS_FILE=$2
			shift;;
 		*) echo "[ERR]: Unknown parameter passed: $1"; exit 1;;
	esac
	shift
done
# Main function, entry point
_fn_main
