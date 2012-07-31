PalominoClusterTool
===================

A tool for creating large database clusters quickly. The goal is to allow an
organisation to build realistically-sized distributed database clusters in a
matter of hours instead of the typical days required now


How to Use It
=============

1. Allocate cluster nodes
2. Give "pdbuser" passwordless SSH login on nodes
3. Give pdbuser passwordless sudo access
4. Pick your database architecture
5. Give roles to the nodes
6. Ask PalominoClusterTool to generate Playbooks/Recipes/Manifests
7. Kick off Ansible/Chef/Puppet job to build cluster


Prerequisites
=============

You need a cluster management tool: Ansible, Chef, or Puppet for example. You
need to use Ubuntu 12.04 LTS on your nodes.


Authors
=======

Tim Ellis, CTO PalominoDB

