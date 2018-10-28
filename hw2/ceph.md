# Ceph: A Scalable, High-Performance Distributed File System  

---- 

# storage

## 1.1 Features  
- architecture  
![arichitecture](https://img-blog.csdn.net/20140923111615901)  
    - client  
    each instance exposes a near-POSIX file system interface to a host or process  
    - 1 OSDs cluster  
    collectively stores all data and metadata  
    - 1 metadata server cluster  
    manages the namespace (file names and directories) while coordinating security, consistency and coherence  

- goal  
    - primary goal  
        - scalability (hundreds of petabytes and beyond)  
        including overall storafe capacity and throughput of the system  
        - performance   
        individual client, directories, or files   
        - reliability  

- feature
    - **decoupled data and metadata**  
    metadata operation *(open, rename)* : done by metadata server cluster  
    client interaction *(reads & writes)* : done by OSDs  
    
    eliminating the need to maintain and distribute object lists  
    simplifying the design of the system  
    reducing the metadata cluster workload

    - **dynamic distributed metadata management**  
    a novel metadata cluster architecture based on Dynamic Subtree Partitioning (adaptively and intelligently distributes responsibility for managing the file system directory hierachy among tens or even hundreds of MDSs)  

    effectively utilize available MDS resources under any workload and achieve near linear scaling in the number of MDSs
    - **reliable automatic distributed object storage**  
    data megration responsibility, relication, failure detection, and failure recovery : done by cluster of OSDs  
    OSDs provide client & metadata servers: a single logical object store

    more effectively leverange the intelligence (CPU and memory) present on each OSD to achieve reliable, highly available object storage with linear scaling  

- rados *( Reliable Autonomic Distributed Object Store)*  
**CEPH's low level: RADOS**
![ceph-storage-architecture](https://img-blog.csdn.net/20151128093736929?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)   
    - architecture  
        - SOD *(object storage device)*  
        unreliable object storage devices
        - monitor  
        Maintain the global status of the entire Ceph cluster.  
    - feature  
        - cluster map  
        - placement group
        - device state
        - map propagation  
![RADOS](https://img-blog.csdn.net/20160528195301592)

- client operation  
    - file I/O and capabilities  
    a process open a file  
    -> client sends a request to the MDS cluster  
    MDS traverses the file system hierachy to translate the filename into the file inode  
    - client synchronization  
    **read before write**  
    atomic write  
    multiple clients with multiple writers or mix of reader and writers: revoke previous issued read caching and write buffering capabilities  
    performance killer: so Ceph supports relaxation via a global switch, but it is not a good solution  
    - namespace operations  
    metadata server cluster: manage interaction between client and file system  
    MDS: apply synchronously to read operations and updates

- dynamically distributed metadata  
    - metadata storage
    metadata updates must be committed to disk for safety  
    MDS recovery is not yet implemented  
    when encounters an MDS failure, another node can quickly rescan the journal to recover the critical contents of the failed node's in-memory cache (for quick startup) and in doing so recover the file system state     
    - dynamic subtree partitioning
![metadata-storage](https://img-blog.csdn.net/20140923111728566)  
    Ceph's MDS cluster is based on a dynamic subtree partioning strategy  
    this strategy adaptively distributes cached metadata hierachically across a set of nodes(as the iamge above)  
    - traffic control
    Ceph uses its knowledge of metadata popularity to provide a wide distribution for hot spots only when needed and without incurring the associated overhead and loss of directory locality in the general case.
    Every MDS response provides the client with ipdates about the authority and any replication of the relevent inode and its ancestors.

- distributed object storage
    - data distribution with CRUSH
![CRUSH](https://img-blog.csdn.net/20140923111831653)
    Ceph first map objects into *placement groups* (PGs) using a simple hash function  
    PGs are then assigned to OSDs using CRUSH (Controlled Replication Under Scalable Hashing)  
    CRUSH requires the PGs and an *OSD cluster map* (compact) to locate an object  
    client, OSD, MDS can independently calculate the location of any object  
    the map is infrequently updated  
    solved data distribution problem and the data location problem  
    - replication  
    Lustre: assume one can construct sufficiently reliable OSDs using RAID or fail-over on a SAN  
    Ceph: assume that in a petabyte or exabyte system failure will be the norm rather than the exception, at any point in time serveral OSDs are likely to be inoperable  
    solution: RADOS manages its own replication of data using a variant of primary-copy replication  
    - data safety
![data-safaty](https://img-blog.csdn.net/20140923111944739)
    writing data into shared storage:
        - clients want their updates to be visible
        - clients want to know the data they've written is safely replicated  
    The primary forwards the update to replicas, and replies with an ack after it is applied to all OSDs' in-memory buffer caches, allowing synchronous POSIX calls on the client to return. A final commit is sent (perhaps many seconds later) when data is safely committed to disk.   
    - failure detection  
    RADOS considers two dimensions of OSD liveness:  
        - whether the OSD is reachable
        - whether it is assigned data by CRUSH
    - recovery and cluster updates  
     OSDs maintain a version number for each object and a log of recent changes
    - object storage with EBOFS  
    each Ceph OSD manages its local object storage with EBOFS, an Extent and B-tree based Object File System. 

----

## 1.2 Pros & Cons  
- Pros
    - Open-source: free, cheap
    - unified storage architecture: rich storage characteriestics
    -  advanced design concept: CRUSH algorithm and metadata Dynamic Subtree Partitioning 
    - environment: OpenStack
- Cons
    - high Operation and maintenance cost
    - complecated system, hard to optimization
    - hard to deploy, acquire high operation and maintenance ability
    - risk: system is not mature enough
    - code quality

----

## 1.3 Key indicators

### 1.3.1 OSD performance 

envieonment:  
- 14-node cluster of OSDs
- 400 clients on 20 additional nodes 
![osd-performace](https://img-blog.csdn.net/20140923111903796)  
performance is limited by raw disk bandwidth (around 58 MB/sec)

- performace compared to general-purpose file systems
![fs-compare](https://img-blog.csdn.net/20140923111920046)   

## 1.3.2 write latency  
Because the primary OSD simultaneously retransmits updates to all replicas, small writes incur a minimal latency increase for more than two replicas. For larger writes, the cost of retransmission dominates; 1 MB writes (not shown) take 13 ms for one replica, and 2.5 times longer  (33 ms) for three.  
![write-latency](https://img-blog.csdn.net/20140923112019562)  


## 1.3.3 data distribution and scalability
Because devices can become overfilled or overutilized with small probability, dragging down performance, CRUSH can correct such situations by offloading any fraction of the allocation for OSDs specially marked in the cluster map. Unlike the hash and linear strategies, CRUSH also minimizes data migration under cluster expansion while maintaining a balanced distribution. CRUSH calculations are O(logn) (for a cluster of n OSDs) and take only tens of microseconds, allowing clusters to grow to hundreds of thousands of OSDs. 

![data-distrbution](https://img-blog.csdn.net/20140923112222377)  
OSD write performance scales linearly with the size of the OSD cluster until the switch is saturated at 24 OSDs. CRUSH and hash performance improves when more PGs lower variance in OSD utilization.

## 1.3.4 metadata update latency

Journal entries are first written to the primary OSD and then replicated to any additional OSDs. With a local disk, the initial hop from the MDS to the (local) primary OSD takes minimal time, allowing update latencies for 2× replication similar to 1× in the diskless model. In both cases, more than two replicas
incurs little additional latency because replicas update in parallel.

Figure (a) shows the latency (y) associated with metadata updates in both cases with varying metadata replication (x) (where zero corresponds to no journaling at all). 

Figure (b) shows cumulative time (y) consumed by a client walking 10,000 nested directories with a readdir in each directory and a stat on each file. 

![meta-data](https://img-blog.csdn.net/20140923112407787)

## 1.3.5 metadata read latency
 
A primed MDS cache reduces readdir times. Subsequent stats are not affected, because inode contents are embedded in directories, allowing the full directory contents to be fetched into the MDS cache with a single OSD access. Ordinarily, cumulative stat times would dominate for larger directories. Subsequent MDS interaction can be eliminated by using readdirplus, which explicitly bundles stat and readdir results in a single operation, or by relaxing POSIX to allow stats immediately following a readdir to be served from client caches (the default).

![metadata-read](https://img-blog.csdn.net/20140923112231734)

----

## 1.4 my comment  
- Ceph is suitable for?
    - corporation based on OpenStack
    - has some team members faimiler with Ceph  
    - large node & block storage or small node (about 10 or so)

I think although Ceph has problems like hard to operation and maintain, it is still a good distributed file system in today's situation. And it has a bright future.

- comperasion with other system  

|  | MooseFS | Ceph | ClusterFS | Lustre|  
| :-: | :-: |:-: | :-: | :-: |
| metadata server | singal MDS, exists singal poing failures | multi MDSs no singal point failure | no MDS, not singal point failure | double MDS |  
| FUSE | OK | OK | OK | OK |  
| interface | POSIX | POSIX | POSIX | POSIX/MPI |  
| Redundancy protection | multi copy | multi copy | mirror | none |  
| failure recovery | by hand | automatically migrate data, form new copy | system will automatically deal failures | none |  
| deploy | easy | easy | easy | diffcult |  
| suitable situation | a large number of R/W to small files | small files | large files (has optimization space for small files) | R/W large files |  
| scale | small | middle | middle | heavy |

----

## 1.5 refercences
1. [linux公社 Ceph分布式存储系统](https://www.linuxidc.com/Linux/2016-04/130026.htm)  
2. [Ceph论文译文--Ceph：一个可扩展，高性能分布式文件系统](https://blog.csdn.net/juvxiao/article/details/39495037)
3. [Ceph分布式存储系统介绍](https://blog.csdn.net/shuningzhang/article/details/50081641?utm_source=blogxgwz2)
4. [关于Ceph现状以及未来的一些思考](https://www.cnblogs.com/goldd/p/6610535.html)


----

# 2 Network

## 2.1 服务器
服务器按**机箱架构**进行划分可分为塔式服务器、机架式服务器、机柜式服务器、刀片式服务器

### 2.1.1塔式服务器

#### Pros
* 该种类的服务器应用较多，外观和立式PC相似，较容易理解
* 主板扩展性较强，插槽会多出很多
* 由于塔式服务器的机箱比较大，服务器的配置也可以很高，冗余扩展更可以很齐备，所以它的应用范围非常广
* 无需额外设备，对放置空间没多少要求
* 成本比较低，性能能满足大部分中小企业用户的要求，市场需求空间还是很大的，适合常见的入门级和工作组级服务器应用

#### Cons
* 塔式服务器个头太大，独立性太强，协同工作在空间占用和系统管理上都不方便

[Reference](https://baike.baidu.com/item/%E5%A1%94%E5%BC%8F%E6%9C%8D%E5%8A%A1%E5%99%A8/5863706)

### 2.1.2 机架式服务器

#### Pros
* 和其他两种样式服务器对比，机架式服务器相对于塔式服务器要节约空间
* 4U以上的产品性能较高，可扩展性好
* 管理十分方便，适合大访问量的关键应用

#### Cons
* 因为空间紧凑因而散热较差

[Reference](https://baike.baidu.com/item/%E6%9C%BA%E6%9E%B6%E5%BC%8F%E6%9C%8D%E5%8A%A1%E5%99%A8/485424?fr=aladdin)

### 2.1.3机柜式服务器

#### Pros
* 可应用于内部结构复杂，内部设备较多，有的还具有许多不同的设备单元的业务场景

### 2.1.4 刀片式服务器

#### Pros
* 适用于特殊应用行业和高密度计算环境
* 高可用、高密度、低成本
* 大大降低运行管理费用
* 高处理能力密度，节省宝贵空间和占地费用
* 低耗电降低电费
* 可靠性设计更加完善，减少停机时间
* 光路诊断
* 电缆连接点大大减少
* 冗余交换模块和电缆连接

#### Cons
* 部署刀片数据中心的前期成本较高。
* 无论刀片服务器内置的冗余是多少，都存在所有刀片服务器宕机和故障的可能性。
* 对于拥有一个或两个刀片中心的企业用户来说，购买备用的部件可能很不划算（如备用机箱等）。
* 大多数刀片中心都有特殊的供电需求，这可能意味着特殊电缆的额外前期成本。
* 刀片中心通常采用的是专用网卡和KVM附属设备，有时候还需要特殊电缆或驱动程序。这样你的刀片服务器上运行什么 操作系统就是个问题。
* 多数刀片中心常用的2.5英寸硬盘通常比非刀片服务器上使用的传统3.5英寸SAS/SATA硬盘故障率要高（随着时间的推移，这种缺陷正在得到改进）。
* 一旦你承诺使用刀片中心，再购买刀片服务器时就会受到厂商的限制，这样从价格的角度来看对供应商不利。

[Reference](https://baike.baidu.com/item/%E5%88%80%E7%89%87%E6%9C%8D%E5%8A%A1%E5%99%A8/1375424?fr=aladdin#3)

### 关键考虑因素
* **功耗成本**，需要对业务计划和项目增长计划有预期估计，推算电力需求和电力成本
* **空间资源成本**
* **服务器定位**
* **机房构件成本**，包括散热成本等可持续成本

## 2.2 交换机
交换机分类有，以太网交换机、电话语音交换机、光纤交换机

### 2.2.1 以太网交换机

#### Feature
* 以太网交换机的每个端口都直接与主机相连，并且一般都工作在全双工方式。
* 交换机能同时连通许多对的端口，使每一对相互通信的主机都能像独占通信媒体那样，进行无冲突地传输数据。
* 共享传输媒体的带宽，对于普通10 Mb/s 的共享式以太网，若共有N个用户，则每个用户占有的平均带宽只有总带宽（10 Mb/s）的N分之一。

#### Pros
* 应用最为普遍，价格也较便宜，档次齐全

### 2.2.2 电话语音交换机

#### Feature
是一种特殊用途的用户交换机，外线呼入时，可由任意一部话机应答，并可以转给所需的被叫。

### 2.2.3 光纤交换机

#### Pros
* 传输速率很高
* 支持的传输距离很远
* 抗干扰能力强

#### Cons
* 成本较高
* 适用范围窄

### 2.2.4 关键考虑因素
* 带宽

## 2.3 路由器
厂家：HUAWEI、D-Link、TP-LINK、腾达等

### 2.3.1 关键考虑因素
* 路由转发性能
* 理想吞吐性能
* 抗干扰性能
* 穿墙覆盖性能
* 发热
* 稳定性
* 成本

----

# 3 xPU

## 3.1 Tensor Pro​cessing Unit (TPU)
Vendor: Google.  

Type: Neural processor.  

Example:  
* Reducing word error rates in speech recognition by 30% over traditional approaches.
* Cutting the error rate in an image recognition competition since 2011 from 26% to 3.5%.
* AlphaGo.

### Feature  

The heart of the TPU is a 65,536 8-bit MAC matrix multiply unit that offers a peak throughput of 92 TeraOps/second (TOPS) and a large (28 MiB) software-managed on-chip memory.

### Pros

* The TPU’s deterministic execution model is a better match to the 99th-percentile response-time requirement of our NN applications. 

* The TPU has 25 times as many MACs and 3.5 times as much on-chip memory as the K80 GPU.

* The TPU is on average about 15X - 30X faster than its contemporary GPU or CPU, with TOPS/Watt about 30X - 80X higher.

* The performance/Watt of the TPU is 30X - 80X that of contemporary products; the revised TPU with K80 memory would be 70X - 200X better.

* The TPU has the lowest power—118W per die total (​TPU+Haswell/2​) and 40W per die incremental.

### Cons

* Lower memory bandwidth: Four of the six NN apps are memory-bandwidth limited on the TPU.

* The TPU has poor energy proportionality: at 10% load, the TPU uses 88% of the power it uses at 100%. 

* Architects have neglected important NN tasks.

* For NN hardware, Inferences Per Second (IPS) is an inaccurate summary performance metric.

* Performance counters added as an afterthought for NN hardware.

### Indicators

#### Rooflines, Response-Time, and Throughput
The Y-axis is performance in floating-point operations per second, thus the peak computation rate forms the “flat” part of the roofline. The X-axis is operational intensity, measured as floating-point operations per DRAM byte accessed.
![rootline](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/roofline.png)


#### Cost-Performance, TCO, and Performance/Watt
The TPU server has 17 to 34 times better total-performance/Watt than Haswell, which makes the TPU server 14 to 16 times the performance/Watt of the K80 server.
![performance/watt](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/performance%3Awatt.png)

#### Energy Proportionality
The TPU has the lowest power—118W per die total(​TPU+Haswell/2​) and 40W per die incremental — but it has poor energy proportionality: at 10% load, the TPU uses 88% of the power it uses at 100%.
Haswell is the best at energy proportionality of the group: it uses 56% of the power at 10% load as it does at 100%. 
The K80 is closer to the CPU than the TPU, using 66% of the full load power at 10% workload.


[References]: In-Datacenter Performance Analysis of a Tensor Processing Unit.


## 3.2 Intelligence Processing Unit （IPU）
Vendor: Graphcore.  

Type: Neural processor.

### Feature
* Designed ground-up for MI, both training and deployment.
* Large 16nm custom chip, cluster-able, 2 per PCIe card.
* Over 1000 truly independent processors per chip; all-to-all non-blocking exchange.
* All model state remains on chip; no directly-attached DRAM.
* Mixed-precision floating-point stochastic arithmetic.

### Pros
* DNN performance well beyond Volta and TPU2; efficient without large batches.
* Unprecedented flexibility for non-DNN models; thrives onn sparsity.


[References]: NIPS 2017‌ P‍R‍ESENTATIONS.


## 3.3 DianNao
Vendor: Cambricon.  

Type: AI accelerator.

### Feature
An accelerator with a high throughput, capable of performing 452 GOP/s (key NN operations such as synaptic weight multiplications and neurons outputs additions) in a small footprint of 3.02 mm2 and 485 mW; compared to a 128-bit 2GHz SIMD processor, the accelerator is 117.87x faster, and it can reduce the total energy by 21.08x. 

### Pros
* A synthesized (place & route) accelerator design for large-scale CNNs and DNNs, the state-of-the-art machine- learning algorithms.
* The accelerator achieves high throughput in a small area, power and energy footprint.
* The accelerator design focuses on memory behavior, and measurements are not circumscribed to computational tasks, they factor in the performance and energy impact of memory transfers.

### Indicators

#### Time and Throughput
![speedup](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/speedup.png)

#### Energy
![energy-reduction](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw2/xPU/energy-reduction.png)


[References]: DianNao: A Small-Footprint High-Throughput Accelerator for Ubiquitous Machine-Learning.


## 3.4 Comments
Nowadays, many companys begin to develop their own processing unit to meet that demands for increasing deep learning calculation, to accelerate the speed of training and inferencing models. It costs huge amount of money and people to explore. The xPU is specially made for machine learning and it is greatly optimized on the basis of CPU according to the needs for machine learning. For students who wants to learn machine learning and train some models for practicing, a good CPU or GPU is absolutely enough.

----
# 4 Memory
 

## 4.1. 什么是Memory？
Memory是计算机中重要的部件之一，它是与CPU进行沟通的桥梁。计算机中所有程序的运行都是在内存中进行的，因此Memory的性能对计算机的影响非常大。内存(Memory)也被称为内存储器，其作用是用于暂时存放CPU中的运算数据，以及与硬盘等外部存储器交换的数据。只要计算机在运行中，CPU就会把需要运算的数据调到Memory中进行运算，当运算完成后CPU再将结果传送出来，Memory的运行也决定了计算机的稳定运行。 Memory是由内存芯片、电路板、金手指等部分组成的。

## 4.2. Types

### 4.2.1 只读存储器（ROM）

ROM表示只读存储器（Read Only Memory），在制造ROM的时候，信息（数据或程序）就被存入并永久保存。ROM一般用于存放计算机的基本程序和数据，如BIOS ROM。其物理外形一般是双列直插式（DIP）的集成块。

> Cons:
这些信息只能读出，一般不能写入。

> Pros:
即使机器停电，这些数据也不会丢失。



### 4.2.2 随机存储器（RAM）  
随机存储器（Random Access Memory）表示既可以从中读取数据，也可以写入数据。

> Cons: 当机器电源关闭时，存于其中的数据就会丢失。

> Pros: 既可以从中读取数据，也可以写入数据。

两种广泛使用的现代RAM形式是静态RAM（SRAM）和动态RAM（DRAM） 
- #### 2.2.1 SRAM
在SRAM中，使用六晶体管存储器单元的状态存储一些数据。

> Cons:这种形式的RAM生产成本更高

> Pros:但通常比DRAM更快并且需要更少的动态功率。

在现代计算机中，SRAM通常用作CPU的高速缓冲存储器。

- #### 2.2.2 DRAM
DRAM使用晶体管和电容器对存储一些数据，它们一起构成DRAM单元。电容器保持高或低电荷（分别为1或0），晶体管充当开关，让芯片上的控制电路读取电容器的充电状态或改变它。

> Pros:由于这种形式的存储器比静态RAM更便宜，因此它是现代计算机中使用的计算机存储器的主要形式。

> Cons:更高的功率。
 

静态和动态RAM都被认为是易失性的，因为当从系统断电时它们的状态会丢失或重置。


## 4.3.Technology Development
#### - 内存条
内存芯片的状态一直沿用到286初期，鉴于它存在着无法拆卸更换的弊病，这对于计算机的发展造成了现实的阻碍。有鉴于此，内存条便应运而生了。将内存芯片焊接到事先设计好的印刷线路板上，而电脑主板上也改用内存插槽。这样就把内存难以安装和更换的问题彻底解决了。

#### - DDR
DDRS(Double Data Rate SDRAM）简称DDR，也就是“双倍速率SDRAM”的意思。DDR可以说是SDRAM的升级版本，DDR在时钟信号上升沿与下降沿各传输一次数据，这使得DDR的数据传输速度为传统SDRAM的两倍。由于仅多采用了下降缘信号，因此并不会造成能耗增加。至于定址与控制信号则与传统SDRAM相同，仅在时钟上升缘传输。

#### - DDR2

1.    封装发热量
DDR内存通常采用TSOP芯片封装形式，这种封装形式可以很好的工作在200MHz上，当频率更高时，它过长的管脚就会产生很高的阻抗和寄生电容，这会影响它的稳定性和频率提升的难度。这也就是DDR的核心频率很难突破275MHZ的原因。而DDR2内存均采用FBGA封装形式。不同于目前广泛应用的TSOP封装形式，FBGA封装提供了更好的电气性能与散热性，为DDR2内存的稳定工作与未来频率的发展提供了良好的保障。 DDR2内存采用1.8V电压，相对于DDR标准的2.5V，降低了不少，从而提供了明显的更小的功耗与更小的发热量。

1.   OCD（Off-Chip Driver）：
也就是所谓的离线驱动调整，DDR II通过OCD可以提高信号的完整性。DDR II通过调整上拉（pull-up）/下拉（pull-down）的电阻值使两者电压相等。使用OCD通过减少DQ-DQS的倾斜来提高信号的完整性；通过控制电压来提高信号品质。

1. ODT：
ODT是内建核心的终结电阻器。DDR SDRAM的主板上面为了防止数据线终端反射信号需要大量的终结电阻。它大大增加了主板的制造成本。实际上，不同的内存模组对终结电路的要求是不一样的，终结电阻的大小决定了数据线的信号比和反射率，终结电阻小则数据线信号反射低但是信噪比也较低；终结电阻高，则数据线的信噪比高，但是信号反射也会增加。因此主板上的终结电阻并不能非常好的匹配内存模组，还会在一定程度上影响信号品质。DDR2可以根据自己的特点内建合适的终结电阻，这样可以保证最佳的信号波形。使用DDR2不但可以降低主板成本，还得到了最佳的信号品质，这是DDR不能比拟的。

1. Post CAS
Post CAS：它是为了提高DDR II内存的利用效率而设定的。在Post CAS操作中，CAS信号（读写/命令）能够被插到RAS信号后面的一个时钟周期，CAS命令可以在附加延迟（Additive Latency）后面保持有效。原来的tRCD（RAS到CAS和延迟）被AL（Additive Latency）所取代，AL可以在0，1，2，3，4中进行设置。由于CAS信号放在了RAS信号后面一个时钟周期，因此ACT和CAS信号永远也不会产生碰撞冲突。

#### - DDR3

1.  突发长度（Burst Length，BL）
由于DDR3的预取为8bit， DDR2是4

1. 寻址时序（Timing）
就像DDR2从DDR转变而来后延迟周期数增加一样，DDR3的CL周期也将比DDR2有所提高。DDR2的CL范围一般在2～5之间，而DDR3则在5～11之间。
1.  重置（Reset）
重置是DDR3新增的一项重要功能，并为此专门准备了一个引脚当Reset命令有效时，DDR3内存将停止所有操作，并切换至最少量活动状态，以节约电力。

1. DDR3新增ZQ校准功能
ZQ也是一个新增的脚，在这个引脚上接有一个240欧姆的低公差参考电阻。这个引脚通过一个命令集，通过片上校准引擎（On-Die Calibration Engine，ODCE）来自动校验数据输出驱动器导通电阻与ODT的终结电阻值。当系统发出这一指令后，将用相应的时钟周期（在加电与初始化之后用512个时钟周期，在退出自刷新操作后用256个时钟周期、在其他情况下用64个时钟周期）对导通电阻和ODT电阻进行重新校准。
1.  参考电压分成两个
在DDR3系统中，对于内存系统工作非常重要的参考电压信号VREF将分为两个信号，即为命令与地址信号服务的VREFCA和为数据总线服务的VREFDQ，这将有效地提高系统数据总线的信噪等级。

#### - DDR4
 DDR4相比DDR3最大的区别有三点：
 
1.  16bit预取机制（DDR3为8bit），同样内核频率下理论速度是DDR3的两倍；
 
1.  更可靠的传输规范，数据可靠性进一步提升；
 
1.  工作电压降为1.2V，更节能。

## 4.4.Key indicators 

### 4.4.1 容量：
内存的种类和运行频率会对性能有一定影响，不过相比之下，容量的影响更加大。在其他配置相同的条件下内存越大机器性能也就越高。

内存的工作原理。从功能上理解，我们可以将内存看作是内存控制器与CPU之间的桥梁，内存也就相当于“仓库”。显然，内存的容量决定“仓库”的大小，而内存的速度决定“桥梁”的宽窄，两者缺一不可，这也就是我们常常说道的“内存容量”与“内存速度”。

当内存容量不足，我们运行程序的数据不能调用到内存上运行，就会造成明显的卡顿感，因为内存这座“仓库”空间不够，里面的人已经很多了，想要运行其他程序只能等待里面运行的程序数据先停止运行调出内存。

### 4.4.2 频率：
内存主频和CPU主频一样，习惯上被用来表示内存的速度，它代表着该内存所能达到的最高工作频率。内存主频越高在一定程度上代表着内存所能达到的速度越快。
 
计算机系统的时钟速度是以频率来衡量的。内存频率越高，他们时钟速度也越快，反应越灵敏，自然就更好。但和CPU、GPU不同的是，我们平常说的内存频率是内存的等效频率，而不是内存颗粒实际频率。

晶体振荡器控制着时钟速度，在石英晶片上加上电压，其就以正弦波的形式震动起来，这一震动可以通过晶片的形变和大小记录下来。晶体的震动以正弦调和变化的电流的形式表现出来，这一变化的电流就是时钟信号。而内存本身并不具备晶体振荡器，因此内存工作时的时钟信号是由主板芯片组的北桥或直接由主板的时钟发生器提供的，也就是说内存无法决定自身的工作频率，其实际工作频率是由主板来决定的。

我们可以看到当内存预读取不同，最终的等效速度就有很大的差别，DDR预读取2bit，DDR2预读取4bit，DDR3预读取8bit,DDR4是16bit，所以在内存颗粒的核心频率相同的时候，DDR的等效频率是颗粒核心频率的两倍，DDR2是四倍，DDR3是八倍，DDR4是16倍，也因此DDR4到来让内存等效频率上了一个台阶。而内存等效频率就是内存的最终速度，是反映内存性能的最终体现，同一条内存下频率越高性能越好。

### 4.4.3 带宽：
 内存带宽的计算方法并不复杂，大家可以遵循如下的计算公式：带宽=总线宽度×总线频率×一个时钟周期内交换的数据包个数。很明显，在这些乘数因子中，每个都会对最终的内存带宽产生极大的影响。 
 
 除了内存容量与内存速度，延时周期也是决定其性能的关键。当CPU需要内存中的数据时，它会发出一个由内存控制器所执行的要求，内存控制器接著将要求发送至内存，并在接收数据时向CPU报告整个周期（从CPU到内存控制器，内存再回到CPU）所需的时间。毫无疑问，缩短整个周期也是提高内存速度的关键，这就好比在桥梁上工作的警察，其指挥疏通能力也是决定通畅度的因素之一。更快速的内存技术对整体性能表现有重大的贡献，但是提高内存带宽只是解决方案的一部分，数据在CPU以及内存间传送所花的时间通常比处理器执行功能所花的时间更长，为此缓冲区被广泛应用。其实，所谓的缓冲器就是CPU中的一级缓存与二级缓存，它们是内存这座“大桥梁”与CPU之间的“小桥梁”。 
 
 
 
### 4.4.4 单双通道
单条内存是由64bit的内存控制器控制的，双通道内存的意思就是使用两个64bit内存控制器分别控制两条内存，CPU可分别通过这两条内存寻址、读取数据，从而使内存的理论带宽增加一倍，理论数据存取速度也相应增加一倍，就好比马路由单车道变成双车道，这时两辆车可以同时通过而无需等待。

 
 

## 4.5. My comment
### 如何选购内存
##### 1、内存的品牌

对于选择内存来说，最重要的是稳定性和性能，而内存的做工水平直接会影响到性能、稳定以及超频。
内存颗粒的好坏直接影响到内存的性能，可以说也是内存最重要的核心元件。所以在购买时，尽量选择大厂生产出来的内存颗粒，一般常见的内存颗粒厂商有三星、现代、镁光、南亚、茂矽等，它们都是经过完整的生产工序，因此在品质上都更有保障。而采用这些顶级大厂内存颗粒的内存条品质性能，必然会比其他杂牌内存颗粒的产品要高出许多，金士顿属于大众化品牌，市场占有率最高，是绝大数用户装机首选品牌，高端机建议海盗船、芝奇等也是不错之选，如果注重性价比可以优先考虑威刚、镁光、英睿达、十铨、宇瞻、影驰等内存品牌。
内存PCB电路板的作用是连接内存芯片引脚与主板信号线，因此其做工好坏直接关系着系统稳定性。目前主流内存PCB电路板层数一般是6层，这类电路板具有良好的电气性能，可以有效屏蔽信号干扰。而更优秀的高规格内存往往配备了8层PCB电路板，以起到更好的效能。
　　

##### 2、内存的容量

作为普通消费者而言，内存容量首先是要确保的，内存容量不足会严重影响日常使用体验，而后面说的频率、时序等只是让内存性能更强，我们要“先吃饱，在考虑吃不吃得好。”
　　现在市场上内存容量一般为4G、8G、16G的单条，如果装机用户想要更大的内存可以通过购买多条同品牌同型号的内存进行组建即可，一般常见主板都是两根、四根内存插槽，一些高端主板会更多内存插槽支持。现在主流主板最高能够支持64G内存，而一些高端主板，甚至能够支持128G超大内存，而64位的处理器最大支持内存也就是128G。
　现在对于普通办公电脑来说，8G内存足以，而游戏电脑建议双8G或者16G，而对于一些规划人员或者运算程序的用户，我们可以考虑适当的按需提升。
　

##### 3、内存的代数

现在选DDR4比较好

#####  4、内存的频率 
 
 在相同代数和容量的内存情况下，内存频率越高，则性能就会越高，不过频率越高内存价位随之越高。
 内存的综合性能可以用频率除以CL值得到的数值比较，这个数值能衡量内存的综合性能。但是在日常使用上，频率提升带来性能的提升会比CL值缩小带来性能的提升要大，因此我们在预算有限的情况下，优先考虑内存频率的高低。

##### 5、双通道内存

　　所谓的双通道内存技术，就是一种可以使得电脑的性能进一步提升的手段。简单来说，两个内存由串联方式改良为并联方式，能够得到更大的内存带宽，从而提升内存的速度。在内存单双通道上，建议大家还是选择双通道，比如我要购买8GB内存，可以选择两条4GB，这样价格虽然贵了几十块，但是对于性能提升还是值得的。在时序上，当内存频率足够高了，比如我已经决定购买3200MHz的内存条，那么在都是3200MHz不同品牌内存条里，我们就要开始考虑时序了，这时候时序好坏才是内存的短板。




## 4.6. Reference


1. [《内存》 百度百科](https://baike.baidu.com/item/%E5%86%85%E5%AD%98/103614?fr=aladdin)

2. [《Random access memory》 维基百科](https://en.wikipedia.org/wiki/Random-access_memory#Types)

3. [《DDR4内存》 百度百科](https://baike.baidu.com/item/DDR4%E5%86%85%E5%AD%98?fromtitle=DDR4&fromid=10627930)

4. [《怎样挑选内存》 百度经验](https://jingyan.baidu.com/article/c85b7a645b0599003bac95a6.html)

5. [《关于怎么选购内存 你想知道的都在这里！》](
https://baijiahao.baidu.com/s?id=1596413897685202532&wfr=spider&for=pc)

6. [《如何挑选合适内存 内存选购技巧介绍【详解】》](https://product.pconline.com.cn/itbk/software/dnyw/1802/10845084.html)

----  