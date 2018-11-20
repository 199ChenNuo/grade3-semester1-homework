# How to setup kafka

## Step 1:Download
Download zookeeper and kafka files from apache website.
- zookeeper-3.4.10.tar.gz
- kafka_2.12-2.0.0.tgz

And if you don't have JDK now, you should download jdk and jre first and modify the %JAVA_HOME% environment.
## Step 2:Modify the environment variables
Add two lines in the environment
- zookeeper bin, like:
C:\Program Files\zookeeper-3.4.10\bin
- kafka bin, like:
C:\Program Files\kafka_2.12-2.0.0\bin\windows
## Step 3:Modify zookeeper config file
1. Find .\zookeeper-3.4.10\conf\zoo-sample.cfg and change file name to "zoo.cfg"
2. Modify "zoo.cfg" in two lines, like
    - dataDir=C:/Program Files/zookeeper-3.4.10/data
    - clientPort=2181
## Step 4:Modify kafka config file
1. Find .\kafka_2.12-2.0.0\config\server.properties
2. Modify "server.properties"
    - broker.id=0   # stand for brokerID
    - log.dirs=C:/Program Files/kafka_2.12-2.0.0/kafka-logs
    - zookeeper.connect=localhost:2181 # zookeeper location
## Step 5:Try to run zookeeper
Run "zkserver" in command line. Running sucessfully means you install&run the zookeeper correctly.
## Step 6:Try to run kafka
1. Confirm you have run the zookeeper successfully.
2. Confirm you are in the directory "kafka_2.12-2.0.0\"
3. Type the command below
- "./bin/windows/kafka-server-start" "./config/server.properties"

