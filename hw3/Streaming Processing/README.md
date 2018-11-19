# Streaming Processing

## Scensrio 1: Sum up
* Create the topic for the input stream and output stream:
```
./bin/kafka-topics --create --zookeeper localhost:2181  --replication-factor 1 --partitions 1 --topic sum-input
./bin/kafka-topics --create --zookeeper localhost:2181  --replication-factor 1 --partitions 1 --topic sum-output
```
* SumUpProducer(.java) continuously produces numbers into sum-input topic.  

* SumUpStream(.java) continuously processes the numbers in sum-input topic and put the sum results into sum-output topic.
```java
KStream<Integer, Integer> input = builder.stream("sum-input");
final KTable<Integer, Integer> sumOfOddNumbers = input
		.filter((k, v) -> v % 100 != 0)              // pick number to sum up
		.selectKey((k, v) -> 1)                      // set the key of number to be the same 
		.groupByKey()
		.reduce((v1, v2) -> v1+v2);                  // reduce to message into one by sum
sumOfOddNumbers.toStream().to("sum-output");
```
The structure of topologies:
```
Sub-topologies:
  Sub-topology: 0
    Source: KSTREAM-SOURCE-0000000000 (topics: [sum-input])
      --> KSTREAM-FILTER-0000000001
    Processor: KSTREAM-FILTER-0000000001 (stores: [])
      --> KSTREAM-KEY-SELECT-0000000002
      <-- KSTREAM-SOURCE-0000000000
    Processor: KSTREAM-KEY-SELECT-0000000002 (stores: [])
      --> KSTREAM-FILTER-0000000006
      <-- KSTREAM-FILTER-0000000001
    Processor: KSTREAM-FILTER-0000000006 (stores: [])
      --> KSTREAM-SINK-0000000005
      <-- KSTREAM-KEY-SELECT-0000000002
    Sink: KSTREAM-SINK-0000000005 (topic: KSTREAM-REDUCE-STATE-STORE-0000000003-repartition)
      <-- KSTREAM-FILTER-0000000006
  Sub-topology: 1
    Source: KSTREAM-SOURCE-0000000007 (topics: [KSTREAM-REDUCE-STATE-STORE-0000000003-repartition])
      --> KSTREAM-REDUCE-0000000004
    Processor: KSTREAM-REDUCE-0000000004 (stores: [KSTREAM-REDUCE-STATE-STORE-0000000003])
      --> KTABLE-TOSTREAM-0000000008
      <-- KSTREAM-SOURCE-0000000007
    Processor: KTABLE-TOSTREAM-0000000008 (stores: [])
      --> KSTREAM-SINK-0000000009
      <-- KSTREAM-REDUCE-0000000004
    Sink: KSTREAM-SINK-0000000009 (topic: sum-output)
      <-- KTABLE-TOSTREAM-0000000008
```
* See the result by use consumer cmd tools:
```
./bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic number-sum-output --from-beginning --formatter kafka.tools.DefaultMessageFormatter --property print.key=true --property print.value=true --property key.deserializer=org.apache.kafka.common.serialization.IntegerDeserializer --property value.deserializer=org.apache.kafka.common.serialization.IntegerDeserializer
```
* The Result:（The negative value is caused by overflow of integer value)
![sumup](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw3/Streaming%20Processing/sumupdemo.png)

## Scensrio 2: Word count
* Create the topic for the input stream and output stream(count-input & count-output)
* WordCountProducer(.java) continuously produces sentences into count-input topic.  
* SumUpStream(.java) continuously processes the sentences in count-input topic and put the counting results into count-output topic.  
```java
KStream<String, String> input = builder.stream("count-input");
KTable<String, Long> wordCounts = input
		.flatMapValues(value -> Arrays.asList(value.toLowerCase().split("\\W+")))     // split the sentences into words
        .groupBy((key, value) -> value)      // group by word
        .count();      // count word
wordCounts.toStream().to("count-output", Produced.with(Serdes.String(), Serdes.Long()));
```
* See the result by use consumer cmd tools:
```
./bin/kafka-console-consumer --bootstrap-server localhost:9092 --topic count-output --from-beginning --formatter kafka.tools.DefaultMessageFormatter --property print.key=true --property print.value=true --property key.deserializer=org.apache.kafka.common.serialization.StringDeserializer --property value.deserializer=org.apache.kafka.common.serialization.LongDeserializer

```
* The Result:
![countword](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw3/Streaming%20Processing/wordcountdemo.png)
