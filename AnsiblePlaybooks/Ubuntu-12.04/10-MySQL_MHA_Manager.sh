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

# doesn't need to run as root
if [ $USER == "root" ] ; then
	echo "This script does NOT need to be run as root (probably). If you disagree, edit the script"
	echo "and remove the code that quits when you're root. Exiting abnormally."
	echo ""
	exit 255
fi


# check input is a clusterName
clusterName=$1
if [ "xxx$clusterName" == "xxx" ] ; then
	echo " E Usage: $0 <clusterName>"
	echo " E Currently configured clusters:"
	find /etc/mha -mindepth 1 -type d -printf "%f\n" | awk '{print " - "$_}'
	exit 255
fi
ansibleHosts="/etc/ansible/$clusterName.ini"


# Sanity Check Overall Configuration

# this is a master + slaves setup. there should be at least one slave to fail
# over to, and another that will help rebuild the cluster - realistically,
# there will be 4 or more slaves to the master
echo " - Checking master/slaves configuration."
echo "   You should have one master and at least 2 slaves defined."

mysqlmasters=`awk '/\[.+\]/{m=0};NF && m{t++};/\[mysqlmasters\]/{m=1} END{print t+0}' $ansibleHosts`
if [ $mysqlmasters -ne 1 ] ; then echo "There must be one entry in [mysqlmasters] section in $ansibleHosts - found $mysqlmasters" ; exit 255 ; fi

mysqlslaves=`awk '/\[.+\]/{m=0};NF && m{t++};/\[mysqlslaves\]/{m=1} END{print t+0}' $ansibleHosts`
if [ $mysqlslaves -lt 2 ] ; then echo "There must be two or more entries in [mysqlslaves] section in $ansibleHosts - found $mysqlslaves" ; exit 255 ; fi


# run the playbooks
./lib-WrapPlaybooks.sh $clusterName BaseSaneSystem
./lib-WrapPlaybooks.sh $clusterName MySQLMasterSlaves
./lib-WrapPlaybooks.sh $clusterName MHA

