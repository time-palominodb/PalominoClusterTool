#!/bin/bash

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
	echo " E Usage: $0 <clusterName>"
	echo " E Currently configured clusters:"
	find /etc/palomino -mindepth 1 -type d -printf "%f\n" | awk '{print " - "$_}'
	exit 255
fi
ansibleHosts="/etc/ansible/$clusterName.ini"


if [ ! -r $ansibleHosts ] ; then
	echo " E First you must setup your workstation to build Palomino Cluster Tool!"
	echo " E Suggestion: read README.md and treat it as a checklist."
	exit 255
fi


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


# make sure we can read the passwordless key
if [ ! -r /etc/mha/$clusterName/id_dsa ] ; then
	echo " E Cannot read /etc/mha/$clusterName/id_dsa - give yourself permissions."
	exit 255
fi


# -f 10 - fork ten processes at a time
# -v    - verbosity
ansibleFlags="--forks=10 --inventory-file=$ansibleHosts"


# create a symlink for playbooks to use - remove at end of run
ln -sf /etc/palomino/$clusterName/PalominoClusterToolConfig.yml ./currentPalominoConfiguration.yml


# copy in common scripts, packages, make common configuration changes, etc
echo ""
echo " - `date` :: $0 Running Base Sane System Ansible Playbooks. ========================"
ansible-playbook $ansibleFlags ./BaseSaneSystem/playbooks/setup.yml


echo ""
echo " - `date` :: $0 Hadoop (HDFS) Ansible Playbooks. ========================"
for i in `ls -1 ./Hadoop/playbooks/*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done


echo ""
echo " - `date` :: $0 HBase Ansible Playbooks. ========================"
for i in `ls -1 ./HBase/playbooks/*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done


# clean up the temporary symlink
rm -f ./currentPalominoConfiguration.yml

