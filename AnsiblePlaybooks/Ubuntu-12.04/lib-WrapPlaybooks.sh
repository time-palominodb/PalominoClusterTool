#!/bin/bash

#   Copyright 2012 Tim Ellis
#   CTO: PalominoDB
#   The Palomino Cluster Tool
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# TODO: Convert this to a playbook as well. Ansible supports playbooks-of-playbooks

if [ $USER == "root" ] ; then
	echo "This script does NOT need to be run as root (probably). If you disagree, edit the script"
	echo "and remove the code that quits when you're root. Exiting abnormally."
	echo ""
	exit 255
fi


# check input is a clusterName
clusterName=$1
if [ "xxx$clusterName" == "xxx" ] ; then
	echo " E Usage: $0 <clusterName> <playbookType>"
	echo " E Currently configured clusters:"
	find /etc/mha -mindepth 1 -type d -printf "%f\n" | awk '{print " - "$_}'
	exit 255
fi
ansibleHosts="/etc/ansible/$clusterName.ini"


wrapType=$2
if [ "xxx$wrapType" == "xxx" ] ; then
	echo " E Usage: $0 <clusterName> <wrapType>"
	echo " E You really shouldn't be running this script directly."
	exit 255
fi


if [ ! -r $ansibleHosts ] ; then
	echo " E First you must setup your workstation to build Palomino Cluster Tool!"
	echo " E Suggestion: read README.md and treat it as a checklist."
	exit 255
fi


# -f 10 - fork ten processes at a time
# -v    - verbosity
ansibleFlags="--forks=10 --inventory-file=$ansibleHosts"


# create a symlink for playbooks to use - remove at end of run
ln -sf /etc/palomino/$clusterName/PalominoClusterToolConfig.yml ./currentPalominoConfiguration.yml


echo ""
echo " - `date` :: $0 Running $wrapType Ansible Playbooks. ========================"
for i in `ls -1 ./$wrapType/playbooks/??-*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done


# clean up the temporary symlink earlier created
rm -f ./currentPalominoConfiguration.yml

