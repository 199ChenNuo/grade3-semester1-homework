# cmd command  

1. performace without kafka
see in [part-A](https://github.com/199ChenNuo/grade3-semester1-homework/tree/master/hw3/part%20A)  

1. test-method

    - kafka build-in test tool:
        - kafka-producer-perf-test.bat (there are also .sh for linux)
        - kafka-consumer-perf-test.bat

    - producer parameters:
        - num-records 发送消息的数量
        - topic 主题
        - record-size 单条消息的大小字节
        - throughput 吞储量阀值 10万 就是每秒不超过10万条数据
        - producer-props producer的配置，可以写多个配置用逗号隔开

    - consumer parameters:
        - messages 消费多少消息
        - threads 线程数量
        - zookeeper zookeeper的地址
        - num-fetch-threads 拉取数据的线程数量 即为消费者的数量

1. quantitative analyzing
    1. producer
<code>
kafka-producer-perf-test.bat --num-records xxx --topic testx-x --record-size xxx --throughput xxx --producer-props bootstrap.servers=ip:port
</code>
        -   thread number  

        | No. | topic | thread number | partition | replication | records/second | MB/second | latency(ms) |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test1-1 | 1 | 3 | 1 | 99840.255591 | 19.04 | 5.28 |
        | 2 | test1-2 | 3 | 3 | 1 | 99910.080927 | 19.06 | 8.06 |
        | 3 | test1-3 | 6 | 3 | 1 | 99950.024988 | 19.06 | 5.14 |

        summary:   
            due to fixed throughput, thread numbers doesn't influcence the performance a lot.  
            there is report that says old version can improve producers' throughput by making thread number smaller than partition number. (with fixed partition number)  


        - partition number

        | No. | topic | thread number | partition | replication | records/second | MB/second | latency(ms) |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 3 | 1 | 1 | 99870.168781 | 19.05 | 3.58 |
        | 2 | test2-2 | 3 | 3 | 1 | 99900.099900 | 19.05 | 3.16 |
        | 3 | test2-3 | 3 | 12 | 1 |  99970.008997  | 19.07 | 2.93 |

        summery:  
            the larger the partition is, the bigger the throughput (but in the new version, we have to set up parition)  
            but there is limitation to this improving method;
            on the on hand, partitions may be on different machines, so we can make use of cluster's advantages. on the other hand, a partition matches to a directory. by set patitions on one node to different disks, we can parallel disk management, and make full use of mutil-disks.  
            ![partition](https://images2015.cnblogs.com/blog/1077472/201612/1077472-20161226115551101-978766277.png)  

        - replication number

        | No. | topic | thread number | partition | replication | records/second | MB/second | avg latency(ms) |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test3-1 | 3 | 3 | 1 | 10000000 | 33.91 | 759.47 |
        | 2 | test3-2 | 3 | 3 | 2 | 10000000 | 24.10 | 1047.57 |

        summery:
            larger replication will slow down the MB/second, and almost cut the average latency half down.

        - batch

        batch can optimize I/O. for kafka, it cuts off network transmission overhead, and improves disks writes.   
        before and kafka 0.8.1, sync & asyn producers are seperated. one sends out a single message every time, the other caches messages and then send them together.  
        after and kafka 0.8.2, sync & asyn producers are made into one.  
        in a word, broker is consistently receiving data from network, but writing is periodily. according to test by professional, writing rate can reaches 718MB/s.  
        but the optimazation that batch brings us is not unlimitable. as scale grows, the performance may be affected.  
        ![batch](https://images2015.cnblogs.com/blog/1077472/201612/1077472-20161226133619429-1157988196.png)  
        ![batch-2](https://images2015.cnblogs.com/blog/1077472/201612/1077472-20161226133702320-1447501384.png)

        - record size

        | No. | topic | record size | thread number | partition | replication | records/second | MB/second | latency(ms) |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test4-1 | 100 | 3 | 1 | 1 | 532197 | 50.75 | 230.54 |
        | 2 | test4-2 | 200 | 3 | 1 | 1 | 394944 | 75.33 | 272.89 |
        | 3 | test4-3 | 600 | 3 | 3 | 1 | 183217 | 104.84 | 267.13 |
        | 4 | test4-4 | 1000 | 3 | 3 | 1 | 140984 | 135.45 | 218.71 |

        summery:
        the larger the record size is, the smaller secord sent per second, the larger MB/second


    2. comsumer
<code>
kafka-consumer-perf-test.bat --broker-list ip:port --consumer.config ../../config/consumer.properties --num-fetch-threads x --topic test-x-x --messages xxxx
</code>
        - consumer number

        | No. | topic | consumer number  | partition | replication | records/second | MB/second |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | 
        | 1 | test1-1 | 1 | 3 | 1 | 4016 | 0.3830 |
        | 2 | test1-2 | 3 | 3 | 1 | 3484 | 0.3323 | 

        - partition

        | No. | topic | partition | thread number | partition | replication | records/second | MB/second |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 1 | 3 | 1 | 1 | 4023 | 0.3859 |
        | 2 | test2-2 | 2 | 3 | 1 | 1 | 4315 | 0.4107 |
        | 3 | test2-3 | 6 | 3 | 1 | 1 | 4920 | 0.4155 |

        summery:
            when consumer number are fixed, the more paritions, the higher the throughput. except for that when partitions number is larger than consumer. this would cause some consumer to be doing nothing.





