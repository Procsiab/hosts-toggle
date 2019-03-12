#!/bin/bash

# author: Lorenzo Prosseda
# license: GNU

_HOSTS_FILE="/etc/hosts"
_SETTINGS_FILE="settings.txt"
_SCRIPT_SWITCH=""
_SCRIPT_YES=0
_SCRIPT_BACKUP=1
_SCRIPT_VERSION=1.1
_SCRIPT_VERBOSE=0
_SCRIPT_RET=0

# Echo when verbose flag is passed
function _fn_echoverb {
	if [[ ( _SCRIPT_VERBOSE -eq 1 ) || ( $1 -eq 3 ) ]]
	then
		case $1 in
			0)
				_level="";;
			1)
				_level="[INFO]: ";;
			2)
				_level="[WARN]: ";;
			*)
				_level="[ERR]: ";;
		esac
		echo -e "$_level$2"
	fi
}

# Check if the script was run by user root; exit otherwise
function _fn_check_root {
	if [ "$EUID" -ne 0 ]
		then _fn_echoverb 3 "Unable to write file $_HOSTS_FILE\\n       Try to run this script as root!"
		exit 1
	fi
}

# Back up current hosts file, if any
function _fn_backup {
	if [ -f "$_HOSTS_FILE" ]
	then
		if [ -r $_HOSTS_FILE ]
		then
			if [ $_SCRIPT_BACKUP -eq 1 ]
			then
                _backup_name="$_HOSTS_FILE.bak-$(date +%s%N | cut -b1-13)"
				cp "$_HOSTS_FILE" "$_backup_name" 2>/dev/null
				ret=$?
				if [ $ret -eq 0 ]
				then
					_fn_echoverb 1 "Created backup file: $_backup_name"
				else
					_fn_echoverb 2 "Backup skipped (permission error)"
				fi
			else
				_fn_echoverb 1 "Backup skipped (asked by user)"
			fi
		else
			_fn_echoverb 2 "Backup skipped (permission error)"
		fi
	else
		_fn_echoverb 2 "No hosts file found, so no back up was created!"
		touch "$_HOSTS_FILE"
		_fn_echoverb 1 "Created file hosts"
	fi
}

# Write the IP/Hostnames in the hosts file
function _fn_write_hosts {
	# Check if file is writable and if you run the script as root
	if [ ! -w $_SCRIPT_BACKUP ]
	then
		_fn_check_root
	fi
	# Check if file has the pattern used by this script
	( (cat "$_HOSTS_FILE" | grep "# Hosts-Toggle") && (cat "$_HOSTS_FILE" | grep "# Toggle-Hosts") ) 1> /dev/null 
	ret=$?
	if [ $ret -ne 0 ]
	then
		echo "# Hosts-Toggle" | (tee -a "$_HOSTS_FILE" 1>/dev/null)
		echo "# Toggle-Hosts" | (tee -a "$_HOSTS_FILE" 1>/dev/null)
		_fn_echoverb 1 "Wrote patterns to file hosts"
	fi
	# Clear pre-existing script-added hosts
	sed -i '/# Hosts-Toggle/,/# Toggle-Hosts/{//!d}' "$_HOSTS_FILE"
	if [[ $_SCRIPT_SWITCH = "on"  ]]
	then
		# Insert hosts from settings file between the patterns
		sed -i '/# Hosts-Toggle/r settings.txt' "$_HOSTS_FILE"
		_fn_echoverb 1 "Added custom hosts to file"
		_SCRIPT_RET=1
	elif [[ $_SCRIPT_SWITCH = "off"  ]]
	then
		_fn_echoverb 1 "Removed custom hosts from file"
		_SCRIPT_RET=2
	else
		_fn_echoverb 3 "Wrong usage; you may call this script as hosts-toggle -h to get the available options"
	fi
}

# Guide the user throughout the script, prompt for file problems
function _fn_main {
	_fn_echoverb 0 "*********** HOSTS TOGGLE ***********"
	_fn_echoverb 0 "The hosts defined into settings.txt"
	_fn_echoverb 0 "file will be written to the hosts"

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
		_fn_echoverb 0 ""
		_fn_echoverb 0 "******** HOSTS FILE UPDATED ********"
		_fn_echoverb 0 "You can find a backup file in the"
		_fn_echoverb 0 "same folder, named hosts.bak-ETA"
		if [ $_SCRIPT_RET -eq 1 ]
		then
			echo "++++++++++++ TOGGLE  ON ++++++++++++"
		elif [ $_SCRIPT_RET -eq 2 ]
		then
			echo "------------ TOGGLE OFF ------------"
		fi
	fi
}

# Parse command line arguments
while [ "$#" -gt 0 ]
do
	case $1 in
 		-y)
			_SCRIPT_YES=1;;
 		--no-bak) 
			_SCRIPT_BACKUP=0;;
		-l|--log)
			_SCRIPT_VERBOSE=1;;
		-h|--help)
				echo "Usage: hosts-toggle (on|off) (-y) (-l) (--no-bak) (-s /path/to/settings.txt) (-f /path/to/hosts)"
			exit 0;;
		-v|--version)
			echo "Script version: $_SCRIPT_VERSION"
			exit 0;;
 		on|off) 
			_SCRIPT_SWITCH=$1;;
		-s|--settings)
			_SETTINGS_FILE=$2
			shift;;
		-f|--file)
			_HOSTS_FILE=$2
			shift;;
 		*) _fn_echoverb 3 "Unknown parameter passed: $1"; exit 1;;
	esac
	shift
done
# Main function, entry point
_fn_main
