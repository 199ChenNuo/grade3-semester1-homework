# File "kafka_server.py"

## Change the variables to patch your environment

self.zookeeper_path = YOUR_ZOOKEEPER_PATH

self.kafka_path = YOUR_KAFKA_PATH

## Initicialize the object
ks = kafka_server()

## Run zookeeper and kafka
ks.run()

You can use "ks.list_topics()" to check if run sucessfully. 

If sucessfully, it will return with little latency and show the topics existing now.

Otherwise, ks.run() again.

## Create consumers
ks.consumer(topic,num,server)

topic: message topic

num: number of consumers

server: list of kafka server domain:port

## Create producers
ks.producer(topic,content,server)

topic: message topic

content: the value of message

server: list of kafka server domain:port

## Comment
The consumers will be on until you close the command line window, and will print the message they receive. But the producer will be close when they already sent the message.
