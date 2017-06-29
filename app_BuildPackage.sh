#!/bin/bash

rpmName="SomeApp"

# build a dist folder
cd ./someApp-GUI
npm run build:prod
cd -

# thisFolder=/goes/there/ andThisOne=/goes/here
# trailing slash on source moves contents
rpmDirs=$(cat <<EOF
./someApp-GUI/dist/=/var/www/html/someApp/
./someApp-Backend/backend/=/usr/local/someApp/backend/
./someApp-Backend/logrotate/=/etc/logrotate.d/
./someApp-Backend/rsyslog/=/etc/rsyslog.d/
./someApp-Backend/systemd/=/etc/systemd/system/
./someApp-Backend/config-files/=/usr/local/someApp/config-files/
EOF
)

# there may be single files
rpmFiles=$(cat <<EOF
./gitVersion=/var/www/html/someApp/version.txt
./gitVersion=/usr/local/someApp/version.txt
EOF
)

# ensure a place to put the rpm
mkdir -p rpms

# get the version of the rpm
./getGitRevision.sh > gitVersion

# clean any os x files from the GUI distribution folder
find ./someApp-GUI/dist/ -type f -name .DS_Store -print | xargs rm -f

# build the rpm 
# NOTE: the requirement for ffmpeg must be fulfilled manually at this time
# NOTE: see: https://rpmfusion.org/Configuration 
# NOTE: and then install via: sudo yum install -y ffmpeg --nogpgcheck
fpm -t rpm -p rpms/ -n ${rpmName} -a noarch --rpm-os linux -v $(cat gitVersion) --depends 'ffmpeg' --depends 'mosquitto' --depends 'python-pip' --after-install app_AfterInstall.sh --after-upgrade app_AfterInstall.sh --before-upgrade app_BeforeRemove.sh --before-remove app_BeforeRemove.sh -s dir ${rpmDirs} ${rpmFiles}

# remove the gui dist folder
rm -rf ./someApp-GUI/dist

# finished
