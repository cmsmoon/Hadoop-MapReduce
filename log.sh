#!/bin/bash

#PBS -q hotel
#PBS -N LogSample
#PBS -l nodes=4:ppn=1
#PBS -o log.out
#PBS -e log.err
#PBS -l walltime=00:10:00
#PBS -A ucsb-train10
#PBS -m abe <my email>

#node_number should be consistent with the number of nodes you apply from triton using qsub
node_number=4

# To run this program, you need to make sure ~/log/templog1 file exists as the input file.
# no other files need to be created first. All output files are created under ~/log
# Then you can do "qsub log.sh" to execute this file in a queue
# or you can do "qsub -I", and then "sh log.sh" as an interactive mode

# The above instructions set up 2 nodes and allocates at most 10 mins.
# the trace log files are log.out and log.err

# Set this to location of myHadoop on Triton. That is the system code/libry etc.
# used to run Hadoop/Mapreduce under a supercomputer environment
# Notice the mapreduce Hadoop directory is available in the cluster allocated
#   for exeucting your job (but not necessarily in the triton login node).
export MY_HADOOP_HOME="/opt/hadoop/contrib/myHadoop"

# Set this to the location of Hadoop on TSCC cluster
export HADOOP_HOME="/opt/hadoop/"
export HADOOP_DATA_DIR="/state/partition1/$USER/$PBS_JOBID/data"
export HADOOP_LOG_DIR="/state/partition1/$USER/$PBS_JOBID/log"

#### Set this to the directory where Hadoop configs should be generated
# under "/home/$USER/log/ConfDir"
# that is done automatically based on the above configuration setup.
# Don't change the name of this variable (HADOOP_CONF_DIR) as it is
# required by Hadoop - all config files will be picked up from here
#
# Make sure that this is accessible to all nodes
export HADOOP_CONF_DIR="/home/$USER/MyHadoop/ConfDir/$PBS_JOBID"

# empty data and log directory
rm -rf $HADOOP_DATA_DIR
rm -rf $HADOOP_LOG_DIR

#### Set up the configuration
# Make sure number of nodes is the same as what you have requested from PBS
# usage: $MY_HADOOP_HOME/bin/configure.sh -h
echo "Set up the configurations for myHadoop please..."
$MY_HADOOP_HOME/bin/pbs-configure.sh -n $node_number -c $HADOOP_CONF_DIR

#Format the Hadoop file system initially. It is possible that you donot need to call when executing multiple times.
# But after a while, this file system will be removed anyway, thus we may have to recreate again.
echo "Format HDFS"
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR namenode -format
echo

#### Start the Hadoop cluster
echo "Start all Hadoop daemons"
$HADOOP_HOME/bin/start-all.sh

#Copy data to hadoop
echo "Copy data to HDFS .. "
# remove previous input and output directory in HDFS
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR fs -rmr input
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR fs -rmr output

# Input files
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -copyFromLocal ~/MyHadoop/apache1.splunk.com/access_combined.log input/a

$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -copyFromLocal ~/MyHadoop/apache2.splunk.com/access_combined.log input/b

$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -copyFromLocal ~/MyHadoop/apache3.splunk.com/access_combined.log input/c

#Now we really start to run this job. The intput and output directories are under the hadoop file system.
echo "Run log analysis job .."
time $HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR jar /home/$USER/MyHadoop/loganalysis.jar LogAnalysis input output

echo "Check output files after PC.. but i remove the old output data first"
rm -r ~/MyHadoop/output
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -copyToLocal output ~/MyHadoop/output
cp -r  $HADOOP_HOME/logs ~/MyHadoop

#### Stop the Hadoop cluster
echo "Stop all Hadoop daemons"
$HADOOP_HOME/bin/stop-all.sh
echo

#### Clean up the working directories after job completion
## that may remove the filesystem created.
echo "Clean up .."
$MY_HADOOP_HOME/bin/pbs-cleanup.sh -n $node_number
echo
