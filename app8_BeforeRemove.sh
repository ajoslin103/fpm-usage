#!/bin/bash

rpmName="SomeApp"

# check the argument we were given to determine what to do
# reference: https://www.ibm.com/developerworks/library/l-rpm2/
# 0:uninstall, 1:install, 2:upgrade

runStyle="$1"
echo "${rpmName}.app_BeforeRemove ${runStyle}"

# stop someApp backend service
/bin/systemctl stop someApp

# stop video sync/conversion service
/bin/systemctl stop videoSync.timer

# only run on un-install
if [ "${1:-0}" -gt 0 ]; then
	exit 0
fi

# ensure that httpd is disabled and stopped
systemctl disable httpd &> /dev/null
systemctl stop httpd &> /dev/null

# close the firewall for httpd & s
firewall-cmd  --remove-service http &> /dev/null
firewall-cmd  --remove-service https &> /dev/null
firewall-cmd  --permanent --remove-service http &> /dev/null
firewall-cmd  --permanent --remove-service https &> /dev/null

# disable someApp backend service
/bin/systemctl disable someApp

# disable video sync/conversion service
/bin/systemctl disable videoSync.timer

# sync up systemd
systemctl daemon-reload

exit 0

# finished
