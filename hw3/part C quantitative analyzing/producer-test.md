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

        | No. | topic | thread number | partition | replication | records/second | MB/second | latency |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 3 | 1 | 1 | 99870.168781 | 19.05 | 3.58 |
        | 2 | test2-2 | 3 | 3 | 1 | 99900.099900 | 19.05 | 3.16 |
        | 3 | test2-3 | 3 | 12 | 1 |  99970.008997  | 19.07 | 2.93 |

        summery:  
            the larger the partition is, the bigger the throughput (but in the new version, we have to set up parition)  
            but there is limitation to this improving method;
            ![partition](https://images2015.cnblogs.com/blog/1077472/201612/1077472-20161226115551101-978766277.png)  

        - replication number

        | No. | topic | thread number | partition | replication | records/second | MB/second | latency |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test3-1 | 3 | 3 | 1 |  |  |
        | 2 | test3-2 | 3 | 3 | 2 |  |  |

        - borker number

        | No. | topic | thread number | partition | replication | records/second | MB/second | latency |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 3 | 1 | 1 |  |  |
        | 2 | test2-2 | 3 | 3 | 1 |  |  |

        - record size

        | No. | topic | record size | thread number | partition | replication | records/second | MB/second |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 200 | 3 | 1 | 1 |  |  |
        | 2 | test2-2 | 1000 | 3 | 3 | 1 |  |  |

        - record number

        | No. | topic | record number | thread number | partition | replication | records/second | MB/second |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 1000000 | 3 | 1 | 1 |  |  |
        | 2 | test2-2 | 2000000 | 3 | 3 | 1 |  |  |

    2. comsumer
        - consumer number

        | No. | topic | consumer number | thread number | partition | replication | records/second | MB/second |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 1 | 3 | 1 | 1 |  |  |
        | 2 | test2-2 | 3 | 3 | 3 | 1 |  |  |

        - partition

        | No. | topic | partition | thread number | partition | replication | records/second | MB/second |
        | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
        | 1 | test2-1 | 1 | 3 | 1 | 1 |  |  |
        | 2 | test2-2 | 2 | 3 | 3 | 1 |  |  |


1. test (local producer & consumer)  
kafka-producer-perf-test.bat --num-records 1000000 --topic test1 --record-size 200 --throughput 100000 --producer-props bootstrap.servers=localhost:9092

    | No. | topic | thread number | partition | replication | records/second | MB/second | latency |
    | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |




