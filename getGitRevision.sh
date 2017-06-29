#!/bin/bash

rpmName="SomeApp"

#
# This script will generate a unique version string, including the short hashcode of the commit
#
# The repo must be tagged with a version string in the form: Vers_xx.xy.zz
#
# This script should be located in and run from the top level within the repo
#

if [ ! -z "${1}" ] ; then
	echo "usage: $0"
	echo "note: repo is expected to have a tag of the form: Vers_xx.xy.zz"
	exit 1
fi

revisioncount=$(git rev-list HEAD | wc -l | awk '{printf("%04d\n", $1)}')
projectversion=$(git tag -l Vers* | tail -1)
committed=$(git rev-parse --short HEAD)

echo "${projectversion}-${revisioncount}-r${committed}" | sed 's/-/_/'
