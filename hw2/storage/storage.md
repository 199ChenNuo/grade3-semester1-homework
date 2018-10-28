# storage

---- 

## 1. Features  
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

## 2. Pros & Cons  
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

## 3. Key indicators

### 3.1 OSD performance 

envieonment:  
- 14-node cluster of OSDs
- 400 clients on 20 additional nodes 
![osd-performace](https://img-blog.csdn.net/20140923111903796)  
performance is limited by raw disk bandwidth (around 58 MB/sec)

- performace compared to general-purpose file systems
![fs-compare](https://img-blog.csdn.net/20140923111920046)   

## 3.2 write latency  
Because the primary OSD simultaneously retransmits updates to all replicas, small writes incur a minimal latency increase for more than two replicas. For larger writes, the cost of retransmission dominates; 1 MB writes (not shown) take 13 ms for one replica, and 2.5 times longer  (33 ms) for three.  
![write-latency](https://img-blog.csdn.net/20140923112019562)  


## 3.3 data distribution and scalability
Because devices can become overfilled or overutilized with small probability, dragging down performance, CRUSH can correct such situations by offloading any fraction of the allocation for OSDs specially marked in the cluster map. Unlike the hash and linear strategies, CRUSH also minimizes data migration under cluster expansion while maintaining a balanced distribution. CRUSH calculations are O(logn) (for a cluster of n OSDs) and take only tens of microseconds, allowing clusters to grow to hundreds of thousands of OSDs. 

![data-distrbution](https://img-blog.csdn.net/20140923112222377)  
OSD write performance scales linearly with the size of the OSD cluster until the switch is saturated at 24 OSDs. CRUSH and hash performance improves when more PGs lower variance in OSD utilization.

## 3.4 metadata update latency

Journal entries are first written to the primary OSD and then replicated to any additional OSDs. With a local disk, the initial hop from the MDS to the (local) primary OSD takes minimal time, allowing update latencies for 2× replication similar to 1× in the diskless model. In both cases, more than two replicas
incurs little additional latency because replicas update in parallel.

Figure (a) shows the latency (y) associated with metadata updates in both cases with varying metadata replication (x) (where zero corresponds to no journaling at all). 

Figure (b) shows cumulative time (y) consumed by a client walking 10,000 nested directories with a readdir in each directory and a stat on each file. 

![meta-data](https://img-blog.csdn.net/20140923112407787)

## 3.5 metadata read latency
 
A primed MDS cache reduces readdir times. Subsequent stats are not affected, because inode contents are embedded in directories, allowing the full directory contents to be fetched into the MDS cache with a single OSD access. Ordinarily, cumulative stat times would dominate for larger directories. Subsequent MDS interaction can be eliminated by using readdirplus, which explicitly bundles stat and readdir results in a single operation, or by relaxing POSIX to allow stats immediately following a readdir to be served from client caches (the default).

![metadata-read](https://img-blog.csdn.net/20140923112231734)

----

## 4. my comment  
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

## 5. refercences
1. [linux公社 Ceph分布式存储系统](https://www.linuxidc.com/Linux/2016-04/130026.htm)  
2. [Ceph论文译文--Ceph：一个可扩展，高性能分布式文件系统](https://blog.csdn.net/juvxiao/article/details/39495037)
3. [Ceph分布式存储系统介绍](https://blog.csdn.net/shuningzhang/article/details/50081641?utm_source=blogxgwz2)
4. [关于Ceph现状以及未来的一些思考](https://www.cnblogs.com/goldd/p/6610535.html)
