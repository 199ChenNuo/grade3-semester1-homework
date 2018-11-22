# Network测试
### 测试1：
测试地址：http://speedtest.ofca.gov.hk/speedtest.html

测试数据：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/network1.png?raw=true)

测试结果：

  - | 第一次 | 第二次 | 第三次 | 第四次 | 第五次 | 平均值 |
---|---|---|---|---|---|---
latency(ms) | 277 | 283 | 278 | 285 | 277 | 280 
jitter (ms) | 2|7.7|2.7|10|1.5|4.78
download (Mbps)|4|4.7|4.7|4.8|4.7|4.58
upload(Mbps)| 19|18|17|19|19|18.4


### 测试2：
测试地址：http://www.speedtest.cn/

测试数据：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/network2.png?raw=true)

测试结果：

  - | 第一次 | 第二次 | 第三次 | 平均值 |
---|---|---|---|---|---|---
ping(ms) | 15.04 | 17.73 | 15.19 | 15.98667  
download(Mbps) |7.47|5.79|5.64|	6.3|
upload(Mbps)|56.91|39.78|49.64|48.77667
jitter(ms)|1.09|7.71|4.63|4.476667

### 测试3：
测试地址：http://www.speedtest.net/zh-Hans

测试数据：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/network3.png?raw=true)

测试结果：

  - | 第一次 | 第二次 | 第三次 | 第四次	|第五次|平均值 |
---|---|---|---|---|---|---
ping(ms) | 4	|3	|4|	9	|4|	5.666667
download(Mbps) |14.96|	22.06|	24.86|	24.08|	25.81|	24.91667
upload(Mbps)|73.35|	70.69|	71.01|	71.99|	79.77|	74.25667



### 测试4：
测试地址：http://www.testmyspeed.com/

测试数据：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/network4.png?raw=true)

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/network5.png?raw=true)

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/network6.png?raw=true)

测试结果：

  - | 第一次 | 第二次 | 第三次 | 平均值 |
---|---|---|---|---|---|---
ping(ms) | 370|	236	| 209| 271.6667
download(Mbps) |10.86|	15.09|	11.18|	12.37667
upload(Mbps)|42.31	|53.24|	43.78|	46.44333



### 测试5：
测试工具：iometer

测试结果：见文件network-results.csv:
https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/network-results.csv


# storage 测试
![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/storage1.png?raw=true)

256GBSSD固态硬盘

### 测试1：
windows内置测试: winsat disk

测试结果：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/storage2.png?raw=true)
 
![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/storage3.png?raw=true)
 
![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/pic/storage4.png?raw=true)


测试项目|	第一次|	第二次|第三次	|平均
---|---|---|---|---|---
Disk Random 16.0 Read|	160.11MB/s|	153.41MB/s|131.16MB/s |	148.2267 MB/s
Disk Sequential 64.0 Read|662.98MB/s|739.77MB/s|647.87MB/s |	683.54 MB/s
Disk Sequential 64.0 Write|	183.31MB/s|	187.98MB/s |	171.22MB/s |	180.8367 MB/s
顺序写操作的平均读取时间|0.549ms|0.404ms|0.611ms|0.521333 ms
延迟：95%	|2.607ms	|2.671ms |	2.756ms |	2.678 ms
延迟：最大	|14.938ms	|15.206ms| 	6.285ms| 	12.143 ms
随机写操作的平均读取时间|	0.549ms|	0.597ms| 	0.625ms 	|0.590333 ms
总运行时间|	14.66s|	14.50s|	15.14s|	14.76667s


### 测试2：
测试工具：iometer

测试结果：

见文件storage-results.csv:
https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw3/part%20A/storage-results.csv




