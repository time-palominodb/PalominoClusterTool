# Cookbook Name:: cloudera
# Attributes:: default
#
# Author:: Cliff Erson (<cerson@me.com>)
# Copyright 2012, Riot Games
#
# Significant changes by Tim Ellis in October 2012
# for Palomino Cluster Tool
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# also change JAVA_HOME below if you change this.
default[:java][:install_flavor]           = "oracle"
default[:java][:java_home]                = "/usr/java/default"

# Ganglia multicast IP address - change to Ganglia multicast IP address or collector gmond
default[:ganglia][:ipaddr]                = "10.0.0.201"
default[:ganglia][:port]                  = "8649"

# namenode search is broken, so we hardcode IP address here.
default[:hadoop][:namenode_hostname]      = "hbase-001"
default[:hadoop][:namenode_ipaddress]     = "10.0.0.1"
default[:hadoop][:namenode_port]          = "8020"

# jobtracker search is broken, so we hardcode IP address here.
default[:hadoop][:jobtracker_ipaddress]   = "10.0.0.1"
default[:hadoop][:jobtracker_port]        = "8021"

# zookeeper quorum may be used multiple places
default[:hbase][:zookeeper_quorum]        = "hbase-001,hbase-002,hbase-003"

# hbase info - more is defined below in the hash for hbase-site.xml
default[:hbase][:temp_dir]                = "/var/lib/hbase/tmp"
default[:hbase][:pid_dir]                 = "/var/run/hbase"

default[:hadoop][:version]                = "0.20"
default[:hadoop][:release]                = "3u3"

default[:hadoop][:conf_dir]               = "conf"
default[:hbase][:conf_dir]                = "conf"

# Provide rack info
default[:hadoop][:rackaware][:datacenter] = "default"
default[:hadoop][:rackaware][:rack]       = "rack0"

# Use an alternate yum repo and key
default[:hadoop][:yum_repo_url]           = nil
default[:hadoop][:yum_repo_key_url]       = nil

# generates hadoop-env.sh
default[:hadoop][:hadoop_env] = {
	# also change hadoop.home below if you change this
	"HADOOP_HOME" => "/usr/lib/hadoop-0.20/",
	"HADOOP_NAMENODE_USER" => "hdfs",

	# The only required environment variable is JAVA_HOME.  All others are
	# optional.  When running a distributed configuration it is best to
	# set JAVA_HOME in this file, so that it is correctly defined on
	# remote nodes.

	# typically Java goes into /usr/java/<garbage> and there's a symlink into
	# the most recent version of Java called "default" in /usr/java. that's how
	# it must be installed for this cookbook to work.
	"JAVA_HOME" => "/usr/java/default",

	# Extra Java CLASSPATH elements. Optional.
	# HADOOP_CLASSPATH="<extra_entries>:$HADOOP_CLASSPATH"

	# The maximum amount of (hdfs) heap to use, in MB. Default is 1000.  Useful
	# values are up to about 8GB. beyond that and Java garbage collection can
	# become tricky. Your DataNode hardware should only have a max of about 16GB
	# RAM (assertion expires Q3 2013).
	"HADOOP_HEAPSIZE" => 4000,
	
	# Command specific options appended to HADOOP_OPTS when specified
	"HADOOP_NAMENODE_OPTS" => "-Dcom.sun.management.jmxremote $HADOOP_NAMENODE_OPTS -XX:+UseParallelGC",
	"HADOOP_SECONDARYNAMENODE_OPTS" => "-Dcom.sun.management.jmxremote $HADOOP_SECONDARYNAMENODE_OPTS",
	"HADOOP_DATANODE_OPTS" => "-Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS",
	"HADOOP_BALANCER_OPTS" => "-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS",
	"HADOOP_JOBTRACKER_OPTS" => "-Dcom.sun.management.jmxremote $HADOOP_JOBTRACKER_OPTS",
	# "HADOOP_TASKTRACKER_OPTS" =

	# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
	# "HADOOP_CLIENT_OPTS" => "",

	# Extra ssh options.  Empty by default.
	# "HADOOP_SSH_OPTS" => ""-o ConnectTimeout=1 -o SendEnv=HADOOP_CONF_DIR"",

	# Where log files are stored.  $HADOOP_HOME/logs by default.
	"HADOOP_LOG_DIR" => "/var/log/hadoop",

	# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
	"HADOOP_SLAVES" => "/etc/hadoop/conf/slaves",

	# host:path where hadoop code should be rsync'd from.  Unset by default.
	# "HADOOP_MASTER" => "master:/home/$USER/src/hadoop",

	# Seconds to sleep between slave commands.  Unset by default.  This
	# can be useful in large clusters, where, e.g., slave rsyncs can
	# otherwise arrive faster than the master can service them.
	# "HADOOP_SLAVE_SLEEP" => "0.1",

	# The directory where pid files are stored. /tmp by default.
	# "HADOOP_PID_DIR" => "/var/hadoop/pids",

	# A string representing this instance of hadoop. $USER by default.
	"HADOOP_IDENT_STRING" => "hdfs",
}

default[:hbase][:hbase_site] = {
	"dfs.support.append" => "true",
	"hbase.tmp.dir" => "#{node[:hbase][:temp_dir]}",

	# important to use hostname not IP addr
	"hbase.rootdir" => "hdfs://#{node[:hadoop][:namenode_hostname]}:#{node[:hadoop][:namenode_port]}/hbase",
	# this is NOT the web interface - use anything BUT 60010
	"hbase.master.port" => 60000,

	# but you must setup zookeeper independently (for this Cookbook)
	"hbase.cluster.distributed" => "true",
	"hbase.zookeeper.quorum" => "#{node[:hbase][:zookeeper_quorum]}",
	"hbase.zookeeper.property.clientPort" => 2181,

	# tunings
	"hbase.client.write.buffer" => 8388608,
	"hbase.regionserver.handler.count" => 20,
	"hbase.regionserver.optionallogflushinterval" => 750,
}

default[:hbase][:hbase_env] = {
	# Tell HBase whether it should manage it's own instance of Zookeeper or not.
	"HBASE_MANAGES_ZK" => "false",

	# The java implementation to use. Java 1.6 required.
	"JAVA_HOME" => "/usr/java/default/",

	# Extra Java CLASSPATH elements. Optional.
	# "HBASE_CLASSPATH" => ""

	# The maximum amount of heap to use, in MB. Default is 1000.
	"HBASE_HEAPSIZE" => 3000,

	# for compression - 32-bit then 64-bit options
	# "HBASE_LIBRARY_PATH" => "/usr/lib/hadoop/lib/native/Linux-i386-32",
	"HBASE_LIBRARY_PATH" => "/usr/lib/hadoop/lib/native/Linux-amd64-64",

	# Extra Java runtime options.
	# Below are what we set by default.  May only work with SUN JVM.
	# For more on why as well as other possible settings,
	# see http://wiki.apache.org/hadoop/PerformanceTuning
	# "HBASE_OPTS" => "-ea -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -javaagent:/usr/java/jolokia-jvm-1.0.5-agent.jar=host=localhost,port=8086,agentContext=/jolokia"

	# Uncomment and adjust to enable JMX "# See jmxremote.password and jmxremote.access in $JRE_HOME/lib/management to configure remote password access.
	# More details at: http://java.sun.com/javase/6/docs/technotes/guides/management/agent.html
	"HBASE_JMX_BASE" => "-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false",
	"HBASE_MASTER_OPTS" => "$HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10101",
	"HBASE_REGIONSERVER_OPTS" => "$HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10102",
	"HBASE_THRIFT_OPTS" => "$HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10103",
	"HBASE_ZOOKEEPER_OPTS" => "$HBASE_JMX_BASE -Dcom.sun.management.jmxremote.port=10104",

	# File naming hosts on which HRegionServers will run.
	# $HBASE_HOME/conf/regionservers by default.
	#"HBASE_REGIONSERVERS" => ${HBASE_HOME}/conf/regionservers,

	# Extra ssh options.  Empty by default.
	# "HBASE_SSH_OPTS" => "-o ConnectTimeout=1 -o SendEnv=HBASE_CONF_DIR",

	# Where log files are stored.  $HBASE_HOME/logs by default.
	# "HBASE_LOG_DIR" => "",

	# A string representing this instance of hbase.
	"HBASE_IDENT_STRING" => "PalominoHBaseCluster",

	# The scheduling priority for daemon processes. See 'man nice'.
	# "HBASE_NICENESS" => 10,

	# The directory where pid files are stored. /tmp by default.
	# "HBASE_PID_DIR" => /var/hadoop/pids,

	# Seconds to sleep between slave commands. Unset by default. This
	# can be useful in large clusters, where, e.g., slave rsyncs can
	# otherwise arrive faster than the master can service them.
	# "HBASE_SLAVE_SLEEP" => 0.1,
}

default[:hadoop][:hdfs_site] = {
	# directories for redundancy if the filesystem isn't already redundant,
	# which Palomino recommends
	"dfs.name.dir" => "/var/lib/hadoop/namedir,/disk1/hadoop/namedir,/disk2/hadoop/namedir,/disk3/hadoop/namedir",

	# if this setting is too low, you'll get ERRORs on your DataNodes when the
	# cluster gets to a Real Usage Pattern. unaware of any reason not to set
	# this to at least 4096
	"dfs.datanode.max.xcievers" => 4096,
	
	# a four-disk setup will have a / and three mountpoints for each disk.
	# enumerate them here. you can create a "/disk4" directory on your /
	# partition to store some data on the / partition if you desire, but also
	# consider that logs will go into / and log writing is different access
	# pattern than data writing, so it's probabaly best to dedicate one of
	# those drives to logs data
	"dfs.data.dir" => "/disk1/hadoop/datadir,/disk2/hadoop/datadir,/disk3/hadoop/datadir",
	
	# this is the default if a file doesn't specify its own replication
	# count, but note that you can per-file specify a replication count, so
	# don't set this too high. 3 is a good industry-standard default.
	"dfs.replication" => 3,
	
	# where to store the NameNode fsimage - can be comma-delimited list of
	# where to put hadoop directories
	"hadoop.log.dir" => "/var/log/hadoop",
	"hadoop.conf.dir" => "/etc/hadoop/conf",
	"hadoop.home" => "/usr/lib/hadoop-0.20/",

	# TODO: unsure what these are - research them
	"dfs.namenode.plugins" => "org.apache.hadoop.thriftfs.NamenodePlugin",
	"dfs.datanode.plugins" => "org.apache.hadoop.thriftfs.DatanodePlugin",

	# for defining rack topology
	"topology.script.file.name" => "/usr/local/bin/hadoop-topology/nodes.rb",
}

default[:hadoop][:core_site] = {
	# unix FS to use for temp files
	"hadoop.tmp.dir" => "/tmp",
}

default[:hadoop][:mapred_site] = {
	# mapreduce site settings, the JobTracker IP:port, directories used
	# locally on TaskTracker nodes, max tasks, Java opts.
	# some ambiguity on internet about which parameter name is correct
	"mapreduce.jobtracker.address" => "#{node[:hadoop][:jobtracker_ipaddress]}:#{node[:hadoop][:jobtracker_port]}",
	"mapred.job.tracker"           => "#{node[:hadoop][:jobtracker_ipaddress]}:#{node[:hadoop][:jobtracker_port]}",
	"mapred.local.dir" => "/disk1/hadoop/mapred,/disk2/hadoop/mapred,/disk3/hadoop/mapred",
	"mapred.tasktracker.map.tasks.maximum" => 30,
	"mapred.tasktracker.reduce.tasks.maximum" => 24,
	"mapred.child.java.opts" => "-Xmx512M",
	"mapreduce.jobtracker.staging.root.dir" => "/user/mapred",
	"mapred.system.dir" => "/user/mapred/system",

	# not sure proper values of this setting
	"mapred.tasktracker.tasks.sleeptime-before-sigkill" => 30,
	
	## CAPACITY SCHEDULER SETTINGS ==============================================
	# Percentage of the number of slots in the cluster that are to be available
	# for jobs in this queue.
	"mapred.capacity-scheduler.queue.default.capacity" => 100,
	
	# maximum-capacity defines a limit beyond which a queue cannot use the
	# capacity of the cluster. By default, no limit. maximum-capacity of a
	# queue can only be greater than or equal to its minimum capacity.
	# Default value of -1 implies a queue can use complete capacity of the
	# cluster. This property could be to curtail certain jobs which are
	# long running in nature from occupying more than a certain percentage
	# of the cluster, which in the absence of pre-emption, could lead to
	# capacity guarantees of other queues being affected. One important
	# thing to note is that maximum-capacity is a percentage, so based on
	# the cluster's capacity the max capacity would change. If many
	# nodes/racks get added, max Capacity would increase accordingly.
	"mapred.capacity-scheduler.queue.default.maximum-capacity" => -1,
	
	# If true, priorities of jobs will be taken into account in scheduling
	# decisions.
	"mapred.capacity-scheduler.queue.default.supports-priority" => "false",
	
	# <description> Each queue enforces a limit on the percentage of resources 
	# allocated to a user at any given time, if there is competition for them. 
	# This user limit can vary between a minimum and maximum value. The former
	# depends on the number of users who have submitted jobs, and the latter is
	# set to this property value. For example, suppose the value of this 
	# property is 25. If two users have submitted jobs to a queue, no single 
	# user can use more than 50% of the queue resources. If a third user submits
	# a job, no single user can use more than 33% of the queue resources. With 4 
	# or more users, no user can use more than 25% of the queue's resources. A 
	# value of 100 implies no user limits are imposed. 
	"mapred.capacity-scheduler.queue.default.minimum-user-limit-percent" => 100,
	
	# <description>The maximum number of jobs to be pre-initialized for a user
	# of the job queue.
	"mapred.capacity-scheduler.queue.default.maximum-initialized-jobs-per-user" => 2,
	
	# escription>If true, priorities of jobs will be taken into 
	# account in scheduling decisions by default in a job queue.
	"mapred.capacity-scheduler.default-supports-priority" => "false",
	
	# escription>The percentage of the resources limited to a particular user
	# for the job queue at any given point of time by default.
	"mapred.capacity-scheduler.default-minimum-user-limit-percent" => 100,
	
	# <description>The maximum number of jobs to be pre-initialized for a user
	# of the job queue.
	"mapred.capacity-scheduler.default-maximum-initialized-jobs-per-user" => 2,
	
	# <description>The amount of time in miliseconds which is used to poll 
	# the job queues for jobs to initialize.
	"mapred.capacity-scheduler.init-poll-interval" => 5000,
	
	# <description>Number of worker threads which would be used by
	# Initialization poller to initialize jobs in a set of queue.
	# If number mentioned in property is equal to number of job queues
	# then a single thread would initialize jobs in a queue. If lesser
	# then a thread would get a set of queues assigned. If the number
	# is greater then number of threads would be equal to number of 
	# job queues.
	"mapred.capacity-scheduler.init-worker-threads" => 5,
}

default[:hadoop][:hadoop_policy] = {
	## # Allow only users alice, bob and users in the mapreduce group to
	## # submit jobs to the Map/Reduce cluster:
	## "security.job.submission.protocol.acl" => "alice,bob mapreduce",

	## # Allow only DataNodes running as the users who belong to the group
	## # datanodes to communicate with the NameNode:
	## "security.datanode.protocol.acl" => "datanodes",

	# Allow any user to talk to the HDFS cluster as a DFSClient:
	"security.client.protocol.acl" => "*",
}

default[:hadoop][:hadoop_metrics] = {
	# Configuration of the "dfs" context for null
	#"dfs.class" => "org.apache.hadoop.metrics.spi.NullContext",

	# Configuration of the "dfs" context for ganglia
	# Pick one: Ganglia 3.0 (former) or Ganglia 3.1 (latter)
	# "dfs.class" => "org.apache.hadoop.metrics.ganglia.GangliaContext",
	"dfs.class" => "org.apache.hadoop.metrics.ganglia.GangliaContext31",
	"dfs.period" => "10",
	"dfs.servers" => "#{node[:ganglia][:ipaddr]}:#{node[:ganglia][:port]}",

	# Configuration of the "mapred" context for null
	#"mapred.class" => "org.apache.hadoop.metrics.spi.NullContext",

	# Configuration of the "mapred" context for ganglia
	# Pick one: Ganglia 3.0 (former) or Ganglia 3.1 (latter)
	# "mapred.class" => "org.apache.hadoop.metrics.ganglia.GangliaContext",
	"mapred.class" => "org.apache.hadoop.metrics.ganglia.GangliaContext31",
	"mapred.period" => "10",
	"mapred.servers" => "#{node[:ganglia][:ipaddr]}:#{node[:ganglia][:port]}",

	# Configuration of the "jvm" context for null
	# "jvm.class" => "org.apache.hadoop.metrics.spi.NullContext",

	# Configuration of the "jvm" context for file
	# "jvm.class" => "org.apache.hadoop.metrics.file.FileContext",
	# "jvm.period" => "10",
	# "jvm.fileName" => "/tmp/jvmmetrics.log",

	# Configuration of the "jvm" context for ganglia
	"jvm.class" => "org.apache.hadoop.metrics.ganglia.GangliaContext",
	"jvm.period" => "10",
	"jvm.servers" => "#{node[:ganglia][:ipaddr]}:#{node[:ganglia][:port]}",

	# Configuration of the "ugi" context for null
	"ugi.class" => "org.apache.hadoop.metrics.spi.NullContext",

	# Configuration of the "fairscheduler" context for null
	# "fairscheduler.class" => "org.apache.hadoop.metrics.spi.NullContext",

	# Configuration of the "fairscheduler" context for file
	# "fairscheduler.class" => "org.apache.hadoop.metrics.file.FileContext",
	# "fairscheduler.period" => "10",
	# "fairscheduler.fileName" => "/tmp/fairschedulermetrics.log",

	# Configuration of the "fairscheduler" context for ganglia
	"fairscheduler.class" => "org.apache.hadoop.metrics.ganglia.GangliaContext",
	"fairscheduler.period" => "10",
	"fairscheduler.servers" => "#{node[:ganglia][:ipaddr]}:#{node[:ganglia][:port]}",
}

default[:hadoop][:fair_scheduler] = {
	"pools" => {
		"samplePool" => {
			# Minimum shares of map and reduce slots. Defaults to 0.
			"minMaps" => 10,
			"minReduces" => 5,

			# Limit on running jobs in the pool. If more jobs are submitted,
			# only the first <maxRunningJobs> will be scheduled at any given time.
			# Defaults to infinity or the global poolMaxJobsDefault value below.
			"maxRunningJobs" => "5",

			# Number of seconds after which the pool can preempt other pools'
			# tasks to achieve its min share. Requires preemption to be enabled in
			# mapred-site.xml by setting mapred.fairscheduler.preemption to true.
			# Defaults to infinity (no preemption).
			"minSharePreemptionTimeout" => "300",

			# Pool's weight in fair sharing calculations. Default is 1.0.
			"weight" => "1.0",
		},
	},
	"defaults" => {
		# Default running job limit pools where it is not explicitly set. 
		"poolMaxJobsDefault" => "20",

		# Default running job limit users where it is not explicitly set.
		"userMaxJobsDefault" => "10",

		# Default min share preemption timeout for pools where it is not
		# explicitly configured, in seconds. Requires mapred.fairscheduler.preemption
		# to be set to true in your mapred-site.xml.
		"defaultMinSharePreemptionTimeout" => "600",

		# Preemption timeout for jobs below their fair share, in seconds. 
		# If a job is below half its fair share for this amount of time, it
		# is allowed to kill tasks from other jobs to go up to its fair share.
		# Requires mapred.fairscheduler.preemption to be true in mapred-site.xml.
		"fairSharePreemptionTimeout" => "600",
	}
}

default[:hadoop][:mapred_site]['mapred.fairscheduler.allocation.file'] = "/etc/hadoop-#{node[:hadoop][:version]}/#{node[:hadoop][:conf_dir]}/fair-scheduler.xml"

default[:hadoop][:log4j]['hadoop.root.logger']                                                 = 'INFO,console'
default[:hadoop][:log4j]['hadoop.security.logger']                                             = 'INFO,console'
default[:hadoop][:log4j]['hadoop.log.dir']                                                     = '/var/log/hadoop'
default[:hadoop][:log4j]['hadoop.log.file']                                                    = 'hadoop.log'
default[:hadoop][:log4j]['hadoop.mapreduce.jobsummary.logger']                                 = '${hadoop.root.logger}'
default[:hadoop][:log4j]['hadoop.mapreduce.jobsummary.log.file']                               = 'hadoop-mapreduce.jobsummary.log'
default[:hadoop][:log4j]['log4j.rootLogger']                                                   = '${hadoop.root.logger}, EventCounter'
default[:hadoop][:log4j]['log4j.threshhold']                                                   = 'ALL'
default[:hadoop][:log4j]['log4j.appender.DRFA']                                                = 'org.apache.log4j.DailyRollingFileAppender'
default[:hadoop][:log4j]['log4j.appender.DRFA.File']                                           = '${hadoop.log.dir}/${hadoop.log.file}'
default[:hadoop][:log4j]['log4j.appender.DRFA.DatePattern']                                    = '.yyyy-MM-dd'
default[:hadoop][:log4j]['log4j.appender.DRFA.layout']                                         = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.DRFA.layout.ConversionPattern']                       = '%d{ISO8601} %p %c: %m%n'
default[:hadoop][:log4j]['log4j.appender.console']                                             = 'org.apache.log4j.ConsoleAppender'
default[:hadoop][:log4j]['log4j.appender.console.target']                                      = 'System.err'
default[:hadoop][:log4j]['log4j.appender.console.layout']                                      = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.console.layout.ConversionPattern']                    = '%d{yy/MM/dd HH:mm:ss} %p %c{2}: %m%n'
default[:hadoop][:log4j]['hadoop.tasklog.taskid']                                              = 'null'
default[:hadoop][:log4j]['hadoop.tasklog.iscleanup']                                           = 'false'
default[:hadoop][:log4j]['hadoop.tasklog.noKeepSplits']                                        = '4'
default[:hadoop][:log4j]['hadoop.tasklog.totalLogFileSize']                                    = '100'
default[:hadoop][:log4j]['hadoop.tasklog.purgeLogSplits']                                      = 'true'
default[:hadoop][:log4j]['hadoop.tasklog.logsRetainHours']                                     = '12'
default[:hadoop][:log4j]['log4j.appender.TLA']                                                 = 'org.apache.hadoop.mapred.TaskLogAppender'
default[:hadoop][:log4j]['log4j.appender.TLA.taskId']                                          = '${hadoop.tasklog.taskid}'
default[:hadoop][:log4j]['log4j.appender.TLA.isCleanup']                                       = '${hadoop.tasklog.iscleanup}'
default[:hadoop][:log4j]['log4j.appender.TLA.totalLogFileSize']                                = '${hadoop.tasklog.totalLogFileSize}'
default[:hadoop][:log4j]['log4j.appender.TLA.layout']                                          = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.TLA.layout.ConversionPattern']                        = '%d{ISO8601} %p %c: %m%n'
default[:hadoop][:log4j]['hadoop.security.log.file']                                           = 'SecurityAuth.audit'
default[:hadoop][:log4j]['log4j.appender.DRFAS']                                               = 'org.apache.log4j.DailyRollingFileAppender '
default[:hadoop][:log4j]['log4j.appender.DRFAS.File']                                          = '${hadoop.log.dir}/${hadoop.security.log.file}'
default[:hadoop][:log4j]['log4j.appender.DRFAS.layout']                                        = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.DRFAS.layout.ConversionPattern']                      = '%d{ISO8601} %p %c: %m%n'
default[:hadoop][:log4j]['log4j.category.SecurityLogger']                                      = '${hadoop.security.logger}'
default[:hadoop][:log4j]['log4j.logger.org.apache.hadoop.fs.FSNamesystem.audit']               = 'WARN'
default[:hadoop][:log4j]['log4j.logger.org.jets3t.service.impl.rest.httpclient.RestS3Service'] = 'ERROR'
default[:hadoop][:log4j]['log4j.appender.EventCounter']                                        = 'org.apache.hadoop.metrics.jvm.EventCounter'
default[:hadoop][:log4j]['log4j.appender.JSA']                                                 = 'org.apache.log4j.DailyRollingFileAppender'
default[:hadoop][:log4j]['log4j.appender.JSA.File']                                            = '${hadoop.log.dir}/${hadoop.mapreduce.jobsummary.log.file}'
default[:hadoop][:log4j]['log4j.appender.JSA.layout']                                          = 'org.apache.log4j.PatternLayout'
default[:hadoop][:log4j]['log4j.appender.JSA.layout.ConversionPattern']                        = '%d{yy/MM/dd HH:mm:ss} %p %c{2}: %m%n'
default[:hadoop][:log4j]['log4j.appender.JSA.DatePattern']                                     = '.yyyy-MM-dd'
default[:hadoop][:log4j]['log4j.logger.org.apache.hadoop.mapred.JobInProgress$JobSummary']     = '${hadoop.mapreduce.jobsummary.logger}'
default[:hadoop][:log4j]['log4j.additivity.org.apache.hadoop.mapred.JobInProgress$JobSummary'] = 'false'

