# Host-Toggle

This bash script allows you to *hot-swap* host records in the hosts file, from a text file.

In practice, all the lines contained in the `settings.txt` file will be copied in the `/etc/hosts` file, between two patterns.

## Dependencies

This script relies on *sed* to perform the replacement in files.

## Usage

The basic usage follows:

	sudo sh hosts-toggle.sh on

In this case the script will prompt the user with the steps to perform; note that the `on` or `off` argument is mandatory to invoke the command. More command arguments can be used, as follows:

- **on**: insert all the lines in the `settings.txt` file between the patterns, in the `hosts` file;
- **off**: remove all the lines between the patterns in the `hosts` file;
- **-y**: skip the "are you sure" prompt;
- **-l | --log**: show logging messages for warnings and infos (errors are logged independently from this flag);
- **--no-bak**: skip the back up of the hosts file;
- **-s | --settings <path>**: specify the absolute path to the `settings.txt` file to use;
- **-f | --file <path>**: specify the path for the `hosts` file
- **-v | --version**: prints the version number of the script;
- **-h | --help**: prints the usage hint for the script.

## Backup

The script will backup the hosts file by default, by appending the Unix Epoch in milliseconds to the file name, prepended by the *.bak* extension; backups are stored in the same folder as the new `hosts` file
