Steps to Perform for All Cluster Types
======================================

   1. Edit BaseSaneSystem/templates/etc:apt:sources.list and put in your
      preferred list of servers to get packages from. If your operations department
      has an Apt repo, put that IP address in the template.
   1. Ensure Ansible is installed/working on your management host. This has some
      dependencies of its own. This should take 30 minutes to an hour.
   1. Symlink PalominoClusterToolLayout.ini to the INI file of the cluster type
      you want to build. The files are named like
      "PalominoClusterToolTemplate_<clusterType>.ini". The INI file is formatted as
      an Ansible inventory file and will be copied into /etc/ansible, but will
      not overwrite an existing file in that directory.
   1. Pick a trending solution from the scripts beginning with 20- and run one
      to install monitoring on your cluster.
   1. Pick an alerting solution from the scripts beginning with 30- and run one
      to get alerting on your cluster.


Steps to Set Up MySQL + MHA
===========================

   1. Install the python-mysqldb module ("apt-get install python-mysqldb") on your
      management host. (This step may not be necessary)
   1. Allocate some servers. Database servers should have at least 1.5GB of RAM.
      Do not use t1.micro if you're building EC2 clusters!
   1. Edit PalominoClusterToolLayout.ini and put in your list of servers. Note
      that you should have symlinked this file as part of "for all cluster types"
      instructions.
   1. As a user with sudo access (but don't use sudo to run this script), run 00-Setup_PalominoClusterTool.sh to
      prepare your workstation to build the distributed cluster.
   1. Edit MySQLMasterSlaves/variables-masters.yml and set the MySQL variables
      according to how you'd like. The files have comments to help you decide
      if you're not a guru MySQL DBA.
   1. Edit MySQLMasterSlaves/variables-slaves.yml to set the MySQL slave
      variables to match your slaves which are probably of a different class of
      hardware than the master.
   1. Modify values in the
     /etc/palomino/<clusterName>/PalominoClusterToolConfig.yml to match your
     hardware.
   1. As a non-root user (with Ansible master access), run 10-MySQL_MHA_Manager.sh.

Post-Setup Instructions:

   1. Run masterha_manager --conf=/etc/mha/palominoClusterTool.cnf on the MHA manager
      machine in a screen session. Rationale: typically you want to run masterha_manager
      in a state where you specifically know it's running, and are monitoring its
      status. In a future rev, alerting will be implemented, and your alerting dashboard
      will have a RED CRITICAL state for this service if you don't start it (or if you
      do start it, but a failover happens).


Steps to Set Up Hadoop (HDFS)
=============================

   1. Allocate servers. You'll want at least 1.5GB of RAM for a test setup. If
      you're using EC2, please read about "Hadoop in EC2" and read up on all mailing
      list posts to understand what you're getting into. Short version: you don't
      want to run in EC2 for production, though it should be okay for a functional
      (not operational!) test.
   1. Download the Java 1.6 JDK onto your management node. Put a copy in /tmp and edit
      Hadoop/playbooks/10-installHadoop.yml and you will find something to help get
      it onto your nodes.
   1. Edit PalominoClusterToolLayout.ini and put in your list of servers. Note
      that you should have symlinked this file as part of "for all cluster types"
      instructions. The Hadoop template file and HBase template file are the same
      file.  You do not need to worry about ZooKeeper, HMaster, or RegionServer types
      of machines for a Hadoop cluster. Just ignore those sections, or even delete
      them, unless you'll also be setting up HBase.
   1. Note for installing HBase, you do not need to follow the steps in this
      section, HBase will automatically install Hadoop.


Steps to Set Up HBase
=====================

   1. Allocate servers. You'll want at least 1.5GB of RAM for a test setup. If you're
      using EC2, please read about "Hadoop in EC2" and read up on all mailing list posts
      to understand what you're getting into. Short version: you don't want to run in
      EC2 for production, though it should be okay for a functional (not operational!)
      test.
   1. Download the Java 1.6 JDK onto your management node. Put a copy in /tmp and edit
      Hadoop/playbooks/10-installHadoop.yml and you will find something to help get
      it onto your nodes.
   1. Edit PalominoClusterToolLayout.ini and put in your list of servers. Note
      that you should have symlinked this file as part of "for all cluster types"
      instructions. The Hadoop template file and HBase template file are the same file.
   1. Note for installing HBase, you do not need to follow the steps in the Hadoop
      section, HBase will automatically install Hadoop.


Steps to Set Up Cassandra
=========================

   1. TODO.

License
=======

The Palomino Cluster Tool is Licensed under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License.

