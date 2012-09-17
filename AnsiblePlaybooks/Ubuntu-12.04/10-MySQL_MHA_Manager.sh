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
	find /etc/mha -mindepth 1 -type d -printf "%f\n" | awk '{print " - "$_}'
	exit 255
fi
ansibleHosts="/etc/ansible/$clusterName.ini"


if [ ! -r $ansibleHosts ] ; then
	echo " E First you must setup your workstation to build Palomino Cluster Tool!"
	echo " E Suggestion: read README.md and treat it as a checklist."
	exit 255
fi


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


# make sure we can read the MHA KEY
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


# MySQL Master and Slaves on database nodes
echo ""
echo " - `date` :: $0 Running MySQL Masters/Slaves Ansible Playbooks. ========================"
for i in `ls -1 ./MySQLMasterSlaves/playbooks/*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done

# MHA on MHA manager and MHA nodes
echo ""
echo " - `date` :: $0 Running MHA Ansible Playbooks. ========================"
for i in `ls -1 ./MHA/playbooks/??-*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done


# clean up the temporary symlink
rm -f ./currentPalominoConfiguration.yml

