import threading
import os
import time
from kafka import KafkaConsumer,KafkaProducer

class kafka_server:
    def __init__(self):
        self.zookeeper_path = '''C:/Program Files/zookeeper-3.4.10/'''
        self.kafka_path = '''C:/Program Files/kafka_2.12-2.0.0/'''
        self.prt_mtx = threading.Lock()
        self.consnum = 0
    def zookeeper(self):
        cmd = r'\"%sbin/zkserver'%self.zookeeper_path
        os.popen(cmd)
        print("zkserver already existed")
    def kafka(self):
        cmd = '\"%sbin/windows/kafka-server-start\" \"%sconfig/server.properties\"'%(self.kafka_path,self.kafka_path)
        os.popen(cmd)
        print("kafka server already existed")
    def run(self):
        threading.Thread(target=self.zookeeper,args=()).start()
        time.sleep(1)
        threading.Thread(target=self.kafka,args=()).start()
    def list_topics(self):
        cmd = '\"%sbin/windows/kafka-topics.bat\" --list --zookeeper localhost:2181'%(self.kafka_path)
        print(os.popen(cmd).read())
    def consumer(self,topic,num=1,server=['localhost:9092']):
        for i in range(self.consnum,self.consnum+num):
            con = KafkaConsumer(topic, bootstrap_servers=server)
            threading.Thread(target=self.cons_print,args=(con,i)).start()
        self.consnum += num
    def cons_print(self,consumer,idnum):
        for msg in consumer:
            self.prt_mtx.acquire()
            recv = "[ID:%d][%s][%d:%d] %s" % (idnum, msg.topic, msg.partition, msg.offset, msg.value.decode())
            print(recv)
            self.prt_mtx.release()
    def producer(self,topic,content,server=['localhost:9092']):
        prod = KafkaProducer(bootstrap_servers=server)
        prod.send(topic,content.encode())
        prod.close()

ks = kafka_server()
##ks.run()
##ks.consumer('test_rhj',3)
##ks.producer('test_rhj','hello world')
