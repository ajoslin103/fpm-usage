#!/bin/bash

rpmName="SomeApp"

# check the argument we were given to determine what to do
# reference: https://www.ibm.com/developerworks/library/l-rpm2/
# 0:uninstall, 1:install, 2:upgrade

runStyle="$1"
echo "${rpmName}.app_AfterRemove ${runStyle}"

# only run on un-install
if [ "${1:-0}" -gt 0 ]; then
	exit 0
fi

# cleanup any lingering empty folders
rmdir /var/www/html/* > /dev/null 2>&1

exit 0

# finished
