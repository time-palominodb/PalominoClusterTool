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

# uncomment this section to turn your local host into an Ubuntu software repository.
# this is unlikely to actually work, though, so it's not recommended
## echo " - Configuring Ubuntu software repository"
## 
## echo " - Installing Apache2 Locally"
## sudo apt-get install apache2 || echo " E Failed to install apache2 locally."
## 
## thecwd=`pwd`
## cd /var/www
## [ -d ubuntu ] || sudo mkdir -p ubuntu
## cd ubuntu
## [ -s binary ] || sudo ln -s /var/cache/apt/archives ./binary
## [ -f binary/Packages.gz ] || sudo dpkg-scanpackages binary /dev/null | sudo gzip -9c > binary/Packages.gz
## cd $thecwd
## echo " o This machine is now an Ubuntu repository. If you'd rather use other sources,"
## echo "   edit BaseSaneSystem/templates/etc:apt:sources.list and add your sources there."
## echo ""

# check input is a clusterName
clusterName=$1
if [ "xxx$clusterName" == "xxx" ] ; then
	clusterName='PalominoCluster'
	echo " W Usage: $0 <clusterName>"
	echo " W You'll use the same clusterName for subsequent helper scripts"
	echo " W Continuing with a default clusterName of $clusterName"
fi
sudo mkdir -p /etc/ansible
ansibleHosts="/etc/ansible/$clusterName.ini"


# we'll store our modified config files here
configDir="/etc/palomino/$clusterName"
configFile="/etc/palomino/$clusterName/PalominoClusterToolConfig.yml"
echo " - Making $configDir"
sudo mkdir -p $configDir || echo " E Failed to create $configDir directory for configuration files."
echo " - Generating configuration file"
cat PalominoClusterToolConfig.yml | sed -e "s/__CLUSTERNAME__/$clusterName/g" > /tmp/PalominoClusterToolConfig-$clusterName.yml
echo " - Writing ./PalominoClusterToolConfig.yml into $configFile"
sudo cp /tmp/PalominoClusterToolConfig-$clusterName.yml $configFile


# setup the Ansible inventory
echo " - Configuring Ansible Inventory"
layoutFile='PalominoClusterToolLayout.ini'
if [ ! -e $layoutFile ] ; then
	echo ""
	echo "ERROR: Symlink a PalominoClusterToolTemplate file to $layoutFile, edit it, re-run this script."
	exit 255
fi
if [ ! -e $ansibleHosts ] ; then
	sudo cp $layoutFile $ansibleHosts || echo " E Failed to create $ansibleHosts."
else
	echo " - Not overwriting $ansibleHosts - if you need to make changes, remove the file first."
fi


# generate SSH keypair for MHA to use
if [ ! -e /etc/mha/$clusterName/id_dsa ] ; then
	echo " - Generating an SSH keypair - do not enter passphrase, press ENTER twice if prompted"

	( sudo mkdir -p /etc/mha/$clusterName \
	&& sudo chown -R $USER: /etc/mha/$clusterName \
	&& cd /etc/mha/$clusterName \
	&& ssh-keygen -t dsa -f id_dsa -C 'Palomino Cluster Tool Auto-Generated Private/Public Keypair' >/dev/null )
fi

# if there's a pubkey pair in /etc/mha/<clusterName> already,
# and the config doesn't have entries for it, use it
configPubkeyHashCount=`fgrep -c cluster_sudoUserPublicKey $configFile`
if [ $configPubkeyHashCount == 0 ] ; then
	echo " - Placing cluster_sudoUser keypair information into $configFile"
	tmpFile="/tmp/config_$clusterName"
	cp -f $configFile $tmpFile
	echo "# passwordless SSH keypair, specify here." >> $tmpFile
	echo "# the private key is a file on your filesystem.." >> $tmpFile
	echo "# the pubkey is the actual ASCII text which you can get by doing:" >> $tmpFile
	echo "#   cat /etc/mha/PalominoTest/id_dsa.pub" >> $tmpFile
	echo "# If you're naming your cluster something besides PalominoTest, it should exist" >> $tmpFile
	echo "# as /etc/mha/<clusterName>/id_dsa.pub" >> $tmpFile
	echo "# Note that the SSH keypair is used for both HBase and MHA" >> $tmpFile
	echo "cluster_sudoUserPrivateKey: /etc/mha/$clusterName/id_dsa" >> $tmpFile
	echo "cluster_sudoUserPublicKey: `cat /etc/mha/$clusterName/id_dsa.pub`" >> $tmpFile
	sudo cp -f $tmpFile $configFile 
	sudo rm -f $tmpFile
fi

# sanity check keypair matches
configVariablePubKeyHash=`fgrep cluster_sudoUserPublicKey $configFile | awk '{print $2 $3}' | md5sum`
etcMhaPubKeyHash=`cat /etc/mha/$clusterName/id_dsa.pub | awk '{print $1 $2 }' | md5sum`
if [ "$configVariablePubKeyHash" == "$etcMhaPubKeyHash" ] ; then
	echo " - Configuration pubkey and /etc/mha/$clusterName/id_dsa.pub match. Good."
else
	echo " E Configuration pubkey and /etc/mha/$clusterName/id_dsa.pub mismatch. Bad."
	echo " E You need to edit $configFile and match it with the generated SSH keypair in /etc/mha/$clusterName."
	exit 255
fi


echo ""
echo " ----- Done."
echo ""
echo ' o You may also want to edit MySQLMasterSlaves/variables-[masters|slaves].yml'
echo '   to match your chosen hardware config.'

