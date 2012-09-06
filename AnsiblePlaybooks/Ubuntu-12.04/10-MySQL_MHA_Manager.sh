#!/bin/bash

# TODO: Convert this to a playbook as well. Ansible supports playbooks-of-playbooks

if [ $USER == "root" ] ; then
	echo "This script does NOT need to be run as root (probably). If you disagree, edit the script"
	echo "and remove the code that quits when you're root. Exiting abnormally."
	echo ""
	echo "Example usage:"
	echo "$0"
	echo ""
	exit 255
fi

# -f 10 - fork ten processes at a time
# -v    - verbosity
ansibleFlags='-f 10'
ansibleHosts='/etc/ansible/hosts'

# Sanity Check Overall Configuration

# this is a master + slaves setup. there should be at least one slave to fail
# over to, and another that will help rebuild the cluster - realistically,
# there will be 4 or more slaves to the master
echo " - Checking master/slaves configuration."
echo "   You should have one master and at least 2 slaves defined."
mysqlmasters=`fgrep -c '[mysqlmasters' $ansibleHosts`
mysqlslaves=`fgrep -c '[mysqlslaves' $ansibleHosts`
if [ $mysqlmasters -ne 1 ] ; then
	echo "There must be one [mysqlmasters] section in $ansibleHosts - found $mysqlmasters"
	exit 255
fi
if [ $mysqlslaves -ne 1 ] ; then
	echo "There must be one [mysqlslaves] section in $ansibleHosts - found $mysqlslaves"
	exit 255
fi


# make sure we can read the MHA KEY
if [ ! -r /etc/mha/id_dsa ] ; then
	echo " E Cannot read /etc/mha/id_dsa - give yourself permissions."
	exit 255
fi


# MHA reconfigures replication topology
echo " - Checking MHA configuration. You need one MHA manager running on its"
echo "   own hardware, and MHA nodes running on the DB clients."
mhanodes=`fgrep -c '[mhanodes' $ansibleHosts`
if [ $mhanodes -ne 1 ] ; then
	echo "There must be one [mhanodes] section in $ansibleHosts - found $mhanodes"
	exit 255
fi


# copy in common scripts, packages, make common configuration changes, etc
echo ""
echo " - `date` :: $0 Running MySQL Masters/Slaves Ansible Playbooks. ========================"
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

# HAproxy on the database client nodes
echo ""
echo " - `date` :: $0 Running HAproxy Ansible Playbooks. ========================"
for i in `ls -1 ./HAProxy/playbooks/??-*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done

# Trending and Alerting
echo ""
echo " - `date` :: $0 Running Zabbix Ansible Playbooks. ========================"
for i in `ls -1 ./Zabbix/playbooks/??-*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done

