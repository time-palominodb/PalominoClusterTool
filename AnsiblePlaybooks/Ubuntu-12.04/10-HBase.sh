#!/bin/bash

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
	find /etc/palomino -mindepth 1 -type d -printf "%f\n" | awk '{print " - "$_}'
	exit 255
fi
ansibleHosts="/etc/ansible/$clusterName.ini"


# Sanity Check Overall Configuration
echo " - Checking configuration."
echo "   You should have one NameNode, one HMaster, one Zookeeper Node, and at least 4 DataNodes and RegionServers defined."

namenodes=`awk '/\[.+\]/{m=0};NF && m{t++};/\[namenodes\]/{m=1} END{print t+0}' $ansibleHosts`
if [ $namenodes -ne 1 ] ; then echo "There must be one entry in [namenodes] section in $ansibleHosts - found $namenodes" ; exit 255 ; fi

hmaster=`awk '/\[.+\]/{m=0};NF && m{t++};/\[hmaster\]/{m=1} END{print t+0}' $ansibleHosts`
if [ $hmaster -ne 1 ] ; then echo "There must be one entry in [hmaster] section in $ansibleHosts - found $hmaster" ; exit 255 ; fi

zookeeper=`awk '/\[.+\]/{m=0};NF && m{t++};/\[zookeeper\]/{m=1} END{print t+0}' $ansibleHosts`
if [ $zookeeper -lt 3 ] ; then echo "There must be 3 (or more, preferably odd) entries in [zookeeper] section in $ansibleHosts - found $zookeeper" ; exit 255 ; fi

datanodes=`awk '/\[.+\]/{m=0};NF && m{t++};/\[datanodes\]/{m=1} END{print t+0}' $ansibleHosts`
if [ $datanodes -lt 4 ] ; then echo "There must be 4 (or more) entries in [datanodes] section in $ansibleHosts - found $datanodes" ; exit 255 ; fi

regionservers=`awk '/\[.+\]/{m=0};NF && m{t++};/\[regionservers\]/{m=1} END{print t+0}' $ansibleHosts`
if [ $regionservers -lt 4 ] ; then echo "There must be 4 (or more) entries in [regionservers] section in $ansibleHosts - found $regionservers" ; exit 255 ; fi


# run the playbooks
./lib-WrapPlaybooks.sh $clusterName BaseSaneSystem
./lib-WrapPlaybooks.sh $clusterName Hadoop
./lib-WrapPlaybooks.sh $clusterName HBase

