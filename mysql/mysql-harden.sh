#!/bin/bash

# MYSQL Defaults: USER: root / PASS: <NONE>
# Usage:
#  Setup mysql root password:  ./mysql_secure.sh 'your_new_root_password'
# Tests:
# @ Bitnami Wordpress Image - Lightsail


# Check the bash shell script is being run by root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Setting up Locale
export LC_ALL='en_US.UTF-8'
# Get current password
CURRENT_MYSQL_PASSWORD=`sudo cat /home/bitnami/bitnami_application_password`
if [ -z "$CURRENT_MYSQL_PASSWORD" ];
then
    echo "Please provide the current root password! Bitnami Password was not found!" 1>&2
    exit 1
fi


# Check input params
if [ -n "${1}" -a -z "${2}" ]; then
    # Setup root password
    NEW_MYSQL_PASSWORD="${1}"
elif [ -n "${1}" -a -n "${2}" ]; then
    NEW_MYSQL_PASSWORD="${2}"
else
    echo "Usage:"
    echo "  Setup mysql root password: ${0} 'your_new_root_password'"
    exit 1
fi

#
# Check is expect package installed
#
if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "Can't find expect. Trying install it..."
    apt -y install expect
fi

echo "== Starting securing the MySQL DB ..."
SECURE_MYSQL=$(expect -c "

set timeout 10
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"$CURRENT_MYSQL_PASSWORD\r\"

expect \"VALIDATE PASSWORD plugin?\"
send \"y\r\"

expect \"Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG\"
send \"1\r\"

expect \"Change the password for root ?\"
send \"y\r\"

expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Do you wish to continue with the password provided?\"
send \"y\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

# Execution mysql_secure_installation
echo "${SECURE_MYSQL}"

echo "== Finished securing the MySQL DB !"
echo "== Clearing installed packages ..."
apt -y purge expect
echo "== Done!"
exit 0
