package com.demo;

import org.apache.kafka.common.serialization.Serde;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.KTable;

import java.util.Properties;

public class SumUpStream {
    public static void main(String[] args) throws Exception {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "streams-sumup");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.Integer().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.Integer().getClass());
        props.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 10*1000);

        final Serde<String> stringSerde=Serdes.String();
        final Serde<Long> longSerde=Serdes.Long();
        Consumed<String,String> types=Consumed.with(stringSerde, stringSerde);
        StreamsBuilder builder = new StreamsBuilder();

        KStream<Integer, Integer> input = builder.stream("sum-input");
        final KTable<Integer, Integer> sumOfOddNumbers = input
                .filter((k, v) -> v % 100 != 0)
                .selectKey((k, v) -> 1)
                .groupByKey()
                .reduce((v1, v2) -> v1+v2);
        sumOfOddNumbers.toStream().to("sum-output");

        final Topology topology = builder.build();
        final KafkaStreams streams = new KafkaStreams(topology, props);
        System.out.println(topology.describe());
        streams.start();
    }
}
