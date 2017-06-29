#!/bin/bash

rpmName="SomeApp"

# check the argument we were given to determine what to do
# reference: https://www.ibm.com/developerworks/library/l-rpm2/
# 0:uninstall, 1:install, 2:upgrade

runStyle="$1"
echo "${rpmName}.app_AfterInstall ${runStyle}"

# ensure that httpd is disabled and stopped, starting it is now the job of pss
systemctl disable httpd > /dev/null 2>&1
systemctl stop httpd > /dev/null 2>&1

# remove un-needed modules from the apache config
mv -f /etc/httpd/conf.modules.d/00-dav.conf /etc/httpd/conf.modules.d/00-dav.bak &> /dev/null
mv -f /etc/httpd/conf.modules.d/00-lua.conf /etc/httpd/conf.modules.d/00-lua.bak &> /dev/null
mv -f /etc/httpd/conf.modules.d/00-proxy.conf /etc/httpd/conf.modules.d/00-proxy.bak &> /dev/null

# open the firewall for httpd & s (1st for running config & then for saved config)
firewall-cmd  --add-service http &> /dev/null
firewall-cmd  --add-service https &> /dev/null
firewall-cmd  --permanent --add-service http &> /dev/null
firewall-cmd  --permanent --add-service https &> /dev/null

# disable ipv6 if it is not disabled already
if [[ -z "$(grep disable_ipv6 /etc/sysctl.conf)" ]] ; then
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
	sysctl -p
fi

# ensure the python packages that we need
pip install paho-mqtt
pip install suds

# sync up systemd
systemctl daemon-reload

# enable and start mosquitto
/bin/systemctl enable mosquitto
/bin/systemctl start mosquitto

# enable and start someApp backend service
/bin/systemctl enable someApp
/bin/systemctl start someApp

# enable and start video sync/conversion service
/bin/systemctl enable videoSync.timer
/bin/systemctl start videoSync.timer

# restart rsyslogd to ensure our logging works
/bin/systemctl enable rsyslog
/bin/systemctl restart rsyslog

# # if pss exists on this machine then resart it (to bounce chrome)
# if [[ -x /etc/init.d/pss ]] ; then
# 	service pss restart
# fi

# ensure httpd is running
/bin/systemctl restart httpd

# finished
