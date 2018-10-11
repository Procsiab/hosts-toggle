# Host-Toggle

This bash script allows you to *hot-swap* host records in the hosts file, from a text file.

In practice, all the lines contaimned in the `settings.txt` file will be copied in the `/etc/hosts` file, between two patterns.

## Usage

The basic usage follows:

	sudo sh hosts-toggle.sh

In this case the script will prompt the user with the steps to perform. More command arguments can be used, as follows:

- **on**: insert all the lines in the `settings.txt` file between the patterns, in the `hosts` file;
- **off**: remove all the lines between the patterns in the `hosts` file;
- **-y**: skip the "are you sure" prompt;
- **--no-bak**: skip the back up of the hosts file;
- **-s | --settings <path>**: specify the absolute path to the `settings.txt` file to use;
- **-v | --version**: prints the version number of the script;
- **-h | --help**: prints the usage hint for the script.
