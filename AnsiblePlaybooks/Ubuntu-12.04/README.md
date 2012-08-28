Steps to Perform for All Cluster Types
======================================

   1. Edit BaseSaneSystem/templates/etc:apt:sources.list and put in your
      preferred list of servers to get packages from.


Steps to Set Up MySQL + MHA
===========================

   1. Symlink PalominoClusterToolLayout.ini to the cluster type you want to build.
   2. Edit PalominoClusterToolLayout.ini and put in your list of servers. Copy
      the result into /etc/ansible/hosts.
   2. Edit MySQLMasterSlaves/variables-masters.yml and set the MySQL variables
      according to how you'd like. The files have comments to help you decide
      if you're not a guru MySQL DBA.
   3. Edit MySQLMasterSlaves/variables-slaves.yml to set the MySQL slave
      variables similarly to the master. Your slaves are probably of a different
      class of hardware than the master.
   4. As root, run 00-Setup_PalominoClusterTool.sh.
   5. As a normal user, run 10-MySQL_MHA_Manager.sh.


Steps to Set Up HBase
=====================

   1. TODO.

Steps to Set Up Cassandra
=========================

   1. TODO.

