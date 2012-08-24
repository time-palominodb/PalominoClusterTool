#!/bin/bash

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

# for setting up clusters, we currently only support HAproxy on every DB client
# node, not a central load balancer - if you've configured your own central
# load balancer, have these HAproxy be simple pass-through to that LB
echo " - Checking HAproxy configuration. You should have a load balancer"
echo "   defined on every DB client node."
haproxynodes=`fgrep -c '[haproxynodes' $ansibleHosts`
if [ $haproxynodes -ne 1 ] ; then
	echo "There must be one [haproxynodes] section in $ansibleHosts - found $haproxynodes"
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


# Zero: Make all remote systems sane - copy in common scripts, packages,
# make common configuration changes, etc
echo ""
echo " - `date` :: $0 Running MySQL Masters/Slaves Ansible Playbook. ========================"
ansible-playbook $ansibleFlags ./BaseSaneSystem/setup.yml


# MySQL Master and Slaves on database nodes
echo ""
echo " - `date` :: $0 Running MySQL Masters/Slaves Ansible Playbook. ========================"
for i in `ls -1 ./MySQLMasterSlaves/??-*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done

# MHA on MHA manager and MHA nodes
echo ""
echo " - `date` :: $0 Running MHA Ansible Playbook. ========================"
for i in `ls -1 ./MHA/??-*.yml` ; do
	echo "   - `date` :: $i"
	ansible-playbook $ansibleFlags $i
done

# HAproxy on the database client nodes
echo ""
echo " - `date` :: $0 Running HAproxy Ansible Playbook. ========================"
ansible-playbook $ansibleFlags ./HAProxy/setup.yml

