# Cloudera cookbook

Installs and configures [Cloudera's](http://www.cloudera.com/) Hadoop + Hive + HBase + Thrift.

# Requirements

* Chef 10
* Redhat/CentOS

# Installation Instructions

## Prerequisites: Prepping Nodes for HBase

The HBase cluster needs good mappings from hostnames to IP addresses. Setup DNS
or, worst case, do something like this (where 101..107 are the final octets of
your IP addresses of your HBase machines):

```
# c=1
# for i in 101 102 103 104 105 106 107 ; do \
    echo "10.0.0.$i            hbase-00$c" ; \
    c=$[ $c + 1 ] ; \
  done >> /etc/hosts
```

If the four hard drives aren't mounted, you need to fdisk, mkfs, and mount them.

```
# c=1
# for i in b c d ; do \
    fdisk /dev/sd$i ; \
    mkfs.ext4 /dev/sd${i}1 ; \
    mkdir -p /mnt/disk${c} ; \
    mount /dev/sd${i}1 /mnt/disk${c} ; \
    c=$[ $c + 1 ] ; \
  done
```

Then to make this survive reboots, put them into /etc/fstab:

```
# echo "
/dev/sdb1		/mnt/disk1		ext4	defaults	0 0
/dev/sdc1		/mnt/disk2		ext4	defaults	0 0
/dev/sdd1		/mnt/disk3		ext4	defaults	0 0" >> /etc/fstab
```

The Cookbook as you "git clone" it will be called "cloudera-cookbook," but this
is not what its name should be in Chef. It should be "cloudera." If you name it
anything else, recipes will die with error as they hardcode "cloudera" as the
cookbook name in several places:

```
# knife cookbook upload cloudera
```

First bootstrap the 7 nodes. Call them hbase-001, hbase-002.... If you want the
rest of these instructions to work without alteration. Here's some pseudocode,
but you have to do it manually (or write your own code) since your IP addresses
and node names could be anything.

```
# c=1
# for i in 101 102 103 104 105 106 107 ; do \
    knife bootstrap 10.0.0.$i --node-name hbase-00$c --server-url http://10.0.0.254:4000 ; \
    c=$[ $c + 1 ] ; \
  done
```

We need Java on every node. Oracle makes this extremely difficult to do
non-interactively via Chef, so make it part of your base image, or do it
manually.

Download Java JRE 6 from Oracle, and when you finally have the bin file in your
possession, copy it out to all nodes, run it, and move the resultant directory
to /usr/java:

```
# chmod 755 jre-6u35-linux-x64.bin
# ./jre-6u35-linux-x64.bin
# mkdir -p /usr/java
# mv jre1.6.0_35 /usr/java/
# ln -sf /usr/java/jre1.6.0_35 /usr/java/default
# alternatives --install /etc/alternatives/java java /usr/java/default/bin/java 10 
# ln -sf /etc/alternatives/java /usr/local/bin/java
```

Ensure ntp is setup properly, and make sure all nodes have the same date/time.
Issue this on all nodes if the date/time is broken:

```
# ntpdate 0.centos.pool.ntp.org <--or whatever NTP server you prefer
```

## Cheffery of the Nodes

Give them roles. First, we'll do the "master" node. I'm putting HMaster and
NameNode and JobTracker all on hbase-001. Not precisely how we want for
production. A typical production geometry requires NameNode, JobTracker,
SecondaryNameNode to all be on their own servers.

```
# for i in hadoop_namenode hadoop_jobtracker hbase_master hbase_thrift ; do \
    knife node run_list add hbase-001 recipe[cloudera::$i] ; \
  done
```

Next, we'll do the "slave" nodes. I put DataNode, TaskTracker, and RegionServer
onto each.

```
# for i in hadoop_datanode hadoop_tasktracker hbase_regionserver ; do \
    for j in 2 3 4 5 6 7 ; do \
      knife node run_list add hbase-00$j recipe[cloudera::$i] ; \
    done ; \
  done
```

Edit attributes/default.rb and look for the several hashes of the form:

```
default[:hadoop][:hdfs_site] = {
        "dfs.namenode.plugins" => "org.apache.hadoop.thriftfs.NamenodePlugin",
        "dfs.datanode.plugins" => "org.apache.hadoop.thriftfs.DatanodePlugin",
        "topology.script.file.name" => "/usr/local/bin/hadoop-topology/nodes.rb",
        "dfs.data.dir" => "/disk1/hadoop/datadir,/disk2/hadoop/datadir,/disk3/hadoop/datadir",
} 
```

The Riot Chef Recipes assume you have a topology script for defining your
cluster topology. You must have such a script, even if it will do nothing. The
contents of this script will be generated from topology.rb.erb. I've stubbed
out this template because I could not get it working in short time. Feel free
to offer solutions for bettering this on the mailing list.

There are several other hashes that modification before you begin. For Hadoop
(core-site.xml, hdfs-site.xml, mapred-site.xml, hadoop-env.sh, etc) and HBase
(hbase-env.sh, hbase-site.xml, etc). Just give the entire
`attributes/defaults.rb` a good once-over and make sure everything makes sense to
you.

Do "chef-client" on all your roles. Do it several times, since things always
seem to fail somewhere once or twice. Or read the outputs on every node
carefully to be sure stuff is working (running several times seems to be the
time-wise thing to do).

If you get the error as follows:

```
Errno::EEXIST
-------------
File exists - /etc/hadoop-0.20/conf
```

The solution is to remove the symlink that's there. Here's the symlink rm
command and subsequent chef-client run which should then work.

```
# rm -rf /etc/hadoop-0.20/conf
# chef-client
```

If this continues to be a problem, I'll write removing the symlink into the
recipe itself.


## Post-Chef Manual Steps

Once it's done running, you still won't have a running cluster. NameNode hasn't
been formatted, so it won't start, and so DataNodes won't start, etc. All of
these steps are candidates for being added into Chef Recipes. I've done this in
the past in other Cookbooks, but in the interest of time, I've not done it yet
for this Cookbook.

On your NameNode, issue:

```
# su - hdfs
$ hadoop namenode -format
```

It will ask you if you're sure. Use an uppercase Y. If you use a lowercase Y
it'll just say "format aborted" in a way that makes you think it's erroring,
but it's just refusing to continue without an uppercase Y.

```
12/10/24 18:24:00 INFO namenode.NameNode: STARTUP_MSG: 
/************************************************************
STARTUP_MSG: Starting NameNode
STARTUP_MSG:   host = hbase136/10.0.0.101
STARTUP_MSG:   args = [-format]
STARTUP_MSG:   version = 0.20.2-cdh3u3
STARTUP_MSG:   build = file:///data/1/tmp/topdir/BUILD/hadoop-0.20.2-cdh3u3 -r 318bc781117fa276ae81a3d111f5eeba0020634f; compiled by 'root' on Tue Mar 20 13:46:57 PDT 2012
************************************************************/
Re-format filesystem in /var/lib/hadoop/namedir ? (Y or N) Y
Re-format filesystem in /disk1/hadoop/namedir ? (Y or N) Y
Re-format filesystem in /disk2/hadoop/namedir ? (Y or N) Y
Re-format filesystem in /disk3/hadoop/namedir ? (Y or N) Y
```

After that, the NameNode is formatted. Now create the "hbase" directory inside
HDFS for HBase, and "/user/mapred" for JobTracker:

```
# su - hdfs
$ hadoop fs -mkdir /hbase
$ hadoop fs -chown hbase:hbase /hbase
$ hadoop fs -mkdir /user
$ hadoop fs -mkdir /user/mapred
$ hadoop fs -chown mapred:mapred /user/mapred
```

## The Zookeeper Ensemble

You must also manually set up the Zookeeper ensemble. The Cookbook detailed
herein will install the Zookeeper software on all nodes, but you must edit the
configuration so HBase can use it. This Cookbook assumes an independent
Zookeeper not controlled by HBase. Patches to allow for either with a simple
configuration option are welcome.

Make sure they listen on 2181 (or, if you change it, change it in the
attributes/default.rb as well!). 

```
# cat /etc/zookeeper/zoo.cfg
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/var/zookeeper
clientPort=2181
server.101=hbase-001:2888:3888
server.102=hbase-002:2888:3888
server.103=hbase-003:2888:3888
```

Each node needs a unique integer in the file /var/zookeeper/myid. The integer
from "server.N" must correspond to the myid created on each node. I recommend
using the final octet of the IP address for the integers. The following command
will take care of the "myid" portion for servers using the "10" non-routable IP
address block (modify appropriately for 192 and 172 etc). Run it on all your
Zookeeper servers.

```
# ifconfig | grep addr:10 | awk '{print $2}' | awk -F . '{print $4}' > /var/zookeeper/myid
```

And now start the zookeeper server on every node of the ensemble:

```
# zookeeper-server start
```

Starting the Cluster

Assuming Chef hasn't started all the proper roles (it never seems to succeed
for me), you can start them by having ClusterSSH (or equivalent) and run this
on all your nodes:

```
# zookeeper-server start
# for i in `ls -1 /etc/init.d/hadoop-* | grep -v hbase` ; do $i start ; done
# for i in `ls -1 /etc/init.d/hadoop-* | grep hbase` ; do $i start ; done
```

One would hope simply running "chef-client" would start all the roles. If it
does, then great! If not... the above helps things along a bit.

## Operational Runbooks

If you need to stop/start everything, run the following on EVERY HBase/HDFS
node in the cluster:

```
# for i in `ls -1 /etc/init.d/hadoop-* | grep hbase` ; do $i stop ; done
# for i in `ls -1 /etc/init.d/hadoop-* | grep -v hbase` ; do $i stop ; done
# zookeeper-server stop
   [...do your stuff...]
# zookeeper-server start
# for i in `ls -1 /etc/init.d/hadoop-* | grep -v hbase` ; do $i start ; done
# for i in `ls -1 /etc/init.d/hadoop-* | grep hbase` ; do $i start ; done
```

I'm pretty sure Chef will periodically ensure things are up, so be sure
chef-client isn't on cron during the "do your stuff" part.

If you need to add a node to the Zookeeper ensemble, edit
/etc/zookeeper/zoo.cfg on all of them, do the right thing, and remember to put
an integer into the file /var/zookeeper/myid.

If you need to change any ports (RegionServer, NameNode, HMaster, etc) make the
changes in chef, and do a "chef-client." The configurations will be up-to-date,
but you still must bounce the daemons. Stop/Start everything as noted above.

# License and Authors

Author:: Cliff Erson (<cerson@me.com>)

Author:: Jamie Winsor (<jamie@vialstudios.com>)

Author:: Istvan Szukacs (<istvan.szukacs@gmail.com>)

Author:: Tim Ellis (<timelessness+palomino@gmail.com>)

Copyright 2012, Riot Games, Tim Ellis, PalominoDB

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

