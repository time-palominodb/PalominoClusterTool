PalominoClusterTool
===================

A tool for creating large database clusters quickly. The goal is to allow an
organisation to build realistically-sized distributed database clusters in a
matter of hours instead of the typical days required now. Once the cluster is
built, you should be able to evaluate the cluster properly by running benchmarks
on it and having proper instrumentation to be able to reason logically about
the performance of the cluster.


How to Use It
=============

   1. Allocate cluster nodes, ensure root@node is available to your Management machine
   1. On your Management machine, collect all database-related packages
   1. Decide your distribution, cluster configuration software, and database architecture
   1. Enter [ConfigManager]/[Distribution] directory, edit INI and YAML files
   1. Ask PalominoClusterTool to generate your cluster


What is it?
===========

At its core, the Palomino Cluster Tool is simply a set of playbooks, recipes, and
manifests for setting up complex database clusters. There are some simple scripts
to help it coordinate with your cluster management tool.

One goal is to make sure that once your cluster is set up, there is trending and
alerting set up for the cluster. It is difficult to evaluate the performance of a
database unless it is instrumented properly.


Prerequisites
=============

You need a cluster management tool: Ansible, Chef, or Puppet for example. The end
goal of the Palomino Cluster Tool remains the same, you should be able to set up
the distributed database in hours, so if you do not have one of these tools set up,
we recommend beginning with Ansible since it is the simplest.


Authors
=======

   * Tim Ellis, CTO PalominoDB

