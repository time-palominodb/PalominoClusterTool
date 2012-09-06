Steps to Perform for All Cluster Types
======================================

   1. Edit BaseSaneSystem/templates/etc:apt:sources.list and put in your
      preferred list of servers to get packages from.


Steps to Set Up MySQL + MHA
===========================

   1. Ensure Ansible is installed/working.
   1. Install the python-mysqldb module ("apt-get install python-mysqldb") on your
      Ansible control host.
   1. Symlink PalominoClusterToolLayout.ini to the cluster type you want to build.
   1. Edit PalominoClusterToolLayout.ini and put in your list of servers.
   1. Run 00-Setup_PalominoClusterTool.sh to prepare your workstation to build the
      distributed cluster.
   1. Edit MySQLMasterSlaves/variables-masters.yml and set the MySQL variables
      according to how you'd like. The files have comments to help you decide
      if you're not a guru MySQL DBA.
   1. Edit MySQLMasterSlaves/variables-slaves.yml to set the MySQL slave
      variables similarly to the master. Your slaves are probably of a different
      class of hardware than the master.
   1. As root, run 00-Setup_PalominoClusterTool.sh.
   1. Generate an SSH keypair (must be named "id_dsa" due to limitation in MHA) and
      put details of the keypair in PalominoClusterToolConfig.yml. Also, edit any
      other values in the PalominoClusterToolConfig.yml to your liking.
   1. As a non-root user (with Ansible master access), run 10-MySQL_MHA_Manager.sh.

Post-Setup Instructions:

   1. Run masterha_manager --conf=/etc/mha/palominoClusterTool.cnf on the MHA manager
      machine in a screen session. Rationale: typically you want to run masterha_manager
      in a state where you specifically know it's running, and are monitoring its
      status. In a future rev, alerting will be implemented, and your alerting dashboard
      will have a RED CRITICAL state for this service if you don't start it (or if you
      do start it, but a failover happens).


Steps to Set Up HBase
=====================

   1. TODO.

Steps to Set Up Cassandra
=========================

   1. TODO.

