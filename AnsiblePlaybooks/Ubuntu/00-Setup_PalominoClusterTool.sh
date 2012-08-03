#!/bin/bash

if [ ! "$USER" == "root" ] ; then
	echo ""
	echo "ERROR: Run this as root please."
	exit 255
fi

echo " - Installing Apache2 Locally"
apt-get install apache2

echo " - Configuring Ubuntu software repository"
thecwd=`pwd`
cd /var/www
[ -d ubuntu ] || mkdir -p ubuntu
cd ubuntu
[ -s binary ] || ln -s /var/cache/apt/archives ./binary
[ -f binary/Packages.gz ] || dpkg-scanpackages binary /dev/null | gzip -9c > binary/Packages.gz
cd $thecwd

echo " - Configuring Ansible hosts"

layoutFile='PalominoClusterToolLayout.ini'
if [ ! -e $layoutFile ] ; then
	echo ""
	echo "ERROR: Copy a PalominoClusterToolTemplate file to $layoutFile, edit it, re-run this script."
	exit 255
fi
palominoAnsible=`grep -c PalominoClusterTool /etc/ansible/hosts`
if [ $palominoAnsible -eq 0 ] ; then
	cat $layoutFile >> /etc/ansible/hosts
fi

echo ""
echo " o This machine is now an Ubuntu repository. If you'd rather use other sources,"
echo "   edit BaseSaneSystem/templates/etc:apt:sources.list and add your sources there."
echo ""
echo " o Next step: edit PalominoClusterToolConfig.yml."
echo ""
echo ' o You may also want to edit MySQLMasterSlaves/variables-[masters|slaves].yml'
echo '   to match your chosen hardware config.'

