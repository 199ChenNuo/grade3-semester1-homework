# 1 Scalable and Coordinated Scheduling for Cloud-Scale Computing: Apollo  

<center>Eric Boutin, Jaliya Ekanayake, Wei Lin, Bing Shi, and Jingren Zhou,</center> 
<center>Microsoft;  </center>
<center>Zhengping Qian, Ming Wu, and Lidong Zhou,  </center>
<center>Microsoft Research  </center>

## 1.1 Microsoft needs a schedular that:
* scale to make tens of thousands of scheduling decisions per second on a cluster with tens of thousands of servers;  
* maintain fair sharing of resources among different users and groups;  
* make high-quality scheduling decisions that take into account factors such as data locality, job characteristics, and server load, to minimize job latencies while utilizing the resources in a cluster fully.  

## 1.2 Apollo characteristic:  
### 1.2.1 Architectual 
**Job Manager (JM)** is a scheduler that is responsable for scheduling jobs. Each cluster has a Resource **Monitor (RM)** and each server has a **Process Node (PN)**.  
RM and PN coordinate to provide a global view for the JM to reference when making scheduling decisions. Each PN is responsible for managing the resources from local server. RM collect information from PN, then generate the global information and give it to each JM.  
  
  
Apollo architecture overview  
![Apollo Architectura Overview](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/apollo/Apollo-Architectural-Overview.png) 

### 1.2.2 Characteristic  
* a distributed and coordinated architecture  
* minimize jobs's completing-time  
    - Apollo considers various factors holistically and performs scheduling by estimating task completion.
    - Apollo also considers the probability of task failure to calculate the final completion time estimate.  
    - Besides completion time estimation, the task-execution order also matters for overall job latency
   
* Every JM has the whole information of the cluste to making better decision
* A set of Correction Mechanisms  
    - Duplicate Scheduling
    - Randomization
    - Confidence
    - Straggler Detection
* Introduce opportunistic scheduling in Apollo  
    - Randomized Allocation Mechanism  
    - Task Upgrade  

## 1.3 Pros & Cons  

### 1.3.1 pros

1. **High** aggregated scheduling rate at Scale  
Apollo can constantly provide a scheduling rate of above 10,000, reaching up to 20,000 per second in a single cluster.  
Apollo at production  
![Apollo At Production](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/apollo/Comparision-Between-Apollo-And-The-Baseline-Scheduler.png)  

 
2. **High** Scheduling Quality  
Apollo delivers excellent job performance compared with the baseline scheduler and its scheduling quality is close to the optimal case.   
comparision between Apollo and the baseline scheduler  
![comparision between Apollo and the baseline scheduler](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/apollo/Apollo-At-Production.png)  


3. Helpful and accurate **Evaluating Estimates**  
. Apollo provides good estimates on task wait time and CPU time, despite all the challenges, and estimation does help improve scheduling quality.  
how Estimates helps Apollo to do better job   
![Scheduling-Balance](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/apollo/Scheduling-Balance.png)  

4. Correction Effectiveness  
| Conditions (W: wait time) | Trigger rate | Success rate |  
| :-: | :-: | :-: |  
| New expected W significantly higher | 0.12% | 81.3% |  
| Expected W greater than average | 0.12% | 81.3% |  
| Elaspsed W greater than average | 0.17% | 83.0% |


5. **Stable** Matching Efficiency  
Apollo’s matching algorithm has the same asymptotic complexity as a naive greedy algorithm with negligible overhead. It performs significantly better than the greedy algorithm and is within 5% of the optimal scheduling in our simulation.  
![Matching-quality](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/apollo/Matching-Quality.png)  

### 1.3.2 cons  

1. **must** work with stale information (unlike a centralized scheduler)  

2. may experience **degraded scheduler performance** under high contention  
(although this can apply to other architectures as well).  

3. not open sourced  


## 1.4 My comments  
Apollo can achieve high utilization and low latency, while coping well with the dynamics in diverse workloads and large clusters. It is a ideal solution for schale sheduleing. Notice that Apollo has already been deployed in production, its profermance can be guaranteed. However, Apollo is closed, not like open-source Kubernetes.

## 1.5 Conculsion  
- different cluster scheduler architectures  
![different cluster scheduler architectures](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/apollo/Different-Cluster-Scheduler-Architectures.png)  

- architectures classifaction and feature matrix  
![architecture classifcation and feature matrix](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/apollo/Architecture-Classifaction-And-Feature-Matrix.png)   
  Due to Apollo's architecture, Apollo has done great job in scheduling.As a scalable and coordinated scheduling framework for cloud-scale computing, Apollo adopts a distributed and loosely coordinated scheduling architecture that scales well without sacrificing scheduling quality. Each Apollo scheduler considers various factors holistically and performs estimationbased scheduling to minimize task completion time. By maintaining a local task queue on each server, Apollo enables each scheduler to reason about future resource availability and implement a deferred correction mechanism to effectively adjust suboptimal decisions dynamically.   
  To leverage idle system resources gracefully, opportunistic scheduling is used to maximize the overall system utilization. Apollo has been deployed on production clusters at Microsoft: it has been shown to achieve high utilization and low latency, while coping well with the dynamics in diverse workloads and large clusters.  

## 1.6 reference  
1. [Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing (paper)](https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-boutin_0.pdf)  
2. [Presetation for Apollo](https://www.usenix.org/conference/osdi14/technical-sessions/presentation/boutin)  
3. [【每周论文】Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing](https://blog.csdn.net/violet_echo_0908/article/details/78174782)  
4. [The evolution of cluster scheduler architectures](https://www.cl.cam.ac.uk/research/srg/netos/camsas/blog/2016-03-09-scheduler-architectures.html)  


----  


# 2 Large-scale cluster management system: Borg

Borg admits, schedules, starts, restarts, and monitors the full range of applications that Google runs.

Main benefits:
* hides the details of resource management and failure handling.
* operates with very high reliability and availability, and supports applications do the same.
* run workloads across tens of thousands of machines effectively.


## 2.1 Architecture
![borg architecture](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/borg/borg%20architecture.png?raw=true)
A borg cell consists of a set of machines, a logically centralized controller called the Borgmaster, and an agent process called the Borglet thtat runs on each machine in a cell.

### 2.1.1 Basic Workflow: 
* Users configs and submits the job through **borgcfg**, **command-line tools** and **web browsers UI (Sigma)**.
* **Borgmaster** records it persistently in the Paxos store and adds the job's tasks to the pending queue.
* **Scheduler** scans the job and assigns tasks to machines if there are sufficient available resources that meet the job's constraints.
* **Borgmaster** sends **Borglet** request to let it start the job on the machines.

### 2.1.2 Borgmaster
The Borgmaster handles client RPCs that either mutate state or provide read-only access to data, it also manages state machines for all of the objects in the system, communicates with the Borglets, and offers a web UI as a backup to Sigma.
The Borgmaster is logically a single process but is actually replicated five times. Each replica maintains an in-memory copy of most of the state of the cell. But there is only one elected master per cell serves both as the Paxos leader and the state mutator.
A high-fidelity Borgmaster simulator called Fauxmaster can be used to read checkpoint files, and contains a complete copy of the production Borgmaster code, with stubbed-out interfaces to the Borglets. Users can use it to debug failures by interacting with it as if it were a live Borgmaster, with simulated Borglets replaying real interactions from the checkpoint file.

### 2.1.3 Scheduling
The scheduling algorithm has two parts: feasibility checking, to find machines on which the task chould run, and scoring, which picks one of the feasible machines.
In feasibility checking, the scheduler finds a set of machines that meet the task's constraints and also have enough available resources(includes resources can be evicted). If the machine selected doesn't have enough available resources to fit the new task, Borg preempts lower-priority tasks from lowest to highest until it does, and add the preempted tasks to the scheduler's pending queue.
The score takes into account user-specified preferences, but is mostly driven by built-in criteria:
* minimizing the number and priority of preempted tasks
* picking machines that already have a copy of the task's packages.(bottleneck: contention for the local disk where packages are written to.)
* putting a mix of high and low priority tasks onto a single machine to allow the high-priority ones to expand in a load spike.

### 2.1.4 Borglet
The Borglet is a local Borg agent that is present on every machine in a cell.
It starts and stops tasks; restarts them if they fail; manages local resources by manipulating OS kernel settings; rolls over debug logs; reports the state of the machine to the Borgmaster and other monitoring system.
The Borgmaster polls each Borglet every few seconds to retrieve the machine's current state, thus avoiding the need for an explicit flow control mechanism and preventing recovery storms.
For performance scalability, each Borgmaster replica runs a stateless link shard to handle the communication.
For resiliency, the Borglet always reports its full state, the link shards aggregate and compress the information by reporting only differences to the state machines.

### 2.1.5 Scalability
To handle larger cells, scheduler is splited into a separate process so it could operate in parallel with the other Borgmaster functions that are replicated for failure tolerance.
To improve response times, separate threads are added to talk to the Borglets and respond to read-only RPCs.
To make the scheduler more scalable:
* Score caching: Borg caches the scores until the properties of the machine or task change.
* Equivalence classes: Borg only does feasibility and scoring for one task per equivalence class —— a group of tasks with identical requirements.
* Relaxed randomization: Sechduler examines machines in a random order until it has found enough feasible machines to score, and then selects the best within the set. 

## 2.2 Conceptions(Feature)
Users submit their work to Borg in the form of jobs, each of which consists of one or more tasks that all run the same program. Each job runs in one Borg cell, a set of machines that are managed as a unit.

### 2.2.1 Workload
Borg cells run a heterogenous workload with two main parts:
* Long-running services(prod): producets, internal infrastructure services.
* Batch jobs(non-prod).

### 2.2.2 Clusters & Cells
A cluster usually hosts one large cell and may have a few smaller-scale test or special-purpose cells. The machines in a cell are heterogeneous in many dimensions: size (CPU, RAM, disk, network), processor type, performance, and capabilities such as an external IP address or flash storage.

### 2.2.3 Jobs & Tasks
A Borg job's properties include its name, owner, and the number of tasks it has. A job runs in just one cell. Each task maps to a set of Linux processes running in a container on a machine. Most task properties are the same across all tasks in a job but can be overridden. Borg programs are statically linked to reduce dependencies on their runtime environment, and structured as packages of binaries and data files, whose installation is orchestrated by Borg. Most job descriptions are written in the declarative configuration language BCL. A user can change the properties of some or all the tasks in a running job by pushing a new job configuration to Borg, then Borg will update the tasks to the new specification. Some task updates will always require the task to be restarted, some might make the task no longer fit on the machine, and cause it to be stopped and rescheduled, and some can always be done without restarting or moving the task.
![jobs & tasks workflow](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/borg/job:task%20lifetime.png?raw=true)

### 2.2.4 Allocs
A Borg alloc is a reserved set of resources on a machine in which one or more tasks can be run. Allocs can be used to set resources aside for future tasks, to retain resources between stopping a task and starting it again, and to gather tasks from different jobs onto the same machine. An alloc set is like a job which is a group of allocs that reserve resources on multiple machines. 

### 2.2.5 Priority
Borg defines non-overlapping priority bands for different uses, including: monitoring, production, batch, and best effort(testing/free).
A high-priority task can obtain resources at the expense of a lower-priority one, high-priority task can preempt the lower-priority one. Tasks in the production priority is not allowed to preempt one another.

### 2.2.6 Quota
Quota is used to decide which jobs to admit for scheduling. Quota is expressed as a vector of resource quantities (CPU, RAM, disk...) at a given priority, for a period of time. The quantities specify the maximum amount of resources that a user’s job requests can ask for at a time, jobs with insufficient quota will be immediately rejected upon submission.

## 2.3 Utilization

### 2.3.1 Cell Compaction
Given a workload, found out how small a cell it could be fitted into by removing machines until the workload no longer fitted, repeatedly re-packing the workload from scratch to ensure that there isn't any unlucky configuration.

### 2.3.2 Cell Sharing
Nearly all of our machines run both prod and non-prod tasks at the same time: 98% of the machines in shared Borg cells, 83% across the entire set of machines managed by Borg. 
Prod jobs usually reserve resources to handle rare workload spikes, but don’t use these resources most of the time, so Borg can reclaim the unused resources to run much of the non-prod work.

### 2.3.3 Large Cells
Large cells both can allow large computations to be run, and can decrease resource fragmentation. 

## 2.4 Isolation

### 2.4.1 LS tasks
To help with overload and overcommitment, Borg tasks have an appclass. Latency-sensitive (LS) tasks are used for user-facing applications and shared infrastructure services that require fast response to requests. High-priority LS tasks receive the best treatment, and are capable of temporarily starving batch tasks for several seconds at a time.

### 2.4.2 Compressible Resources
Compressible resources are rate-based and can be reclaimed from a task by decreasing its quality of service without killing it; and non-compressible resources (e.g., memory, disk space) which generally cannot be reclaimed without killing the task. If a machine runs out of non-compressible resources, the Borglet immediately terminates tasks, from lowest to highest priority, until the remaining reservations can be met. If the machine runs out of compressible resources, the Borglet throttles usage so that short load spikes can be handled without killing any tasks.

## 2.5 Drawbacks
* Jobs are restrictive as the only grouping mechanism for tasks.
 Borg has no first-class way to manage an entire multi-job service as a single entity, or to refer to related instances of a service
* One IP address per machine complicates things.
In Borg, all tasks on a machine use the single IP address of their host, and thus share the host’s port space. This causes a number of difficulties: Borg must schedule ports as a resource; tasks must pre-declare how many ports they need, and be willing to be told which ones to use when they start; the Borglet must enforce port isolation; and the naming and RPC systems must handle ports as well as IP addresses.
* Optimizing for power users at the expense of casual ones.

## 2.6 Conclusion
* Borg achieves high utilization by combining admission control, efficient task-packing, over-commitment, and machine sharing with process-level performance isolation.
* Borg supports high-availability applications with runtime features that minimize fault-recovery time, and scheduling policies that reduce the probability of correlated failures. 
* Borg simplifies life for its users by offering a declarative job specification language, name service integration, real-time job monitoring, and tools to analyze and simulate system behavior.
I feel really lucky to have experience in using Borg in internal Google. I have used Borg to run some batch jobs, there are lots of other tools corporating with borg well so that a job can be easily configed without much work then everything after that is totally automated and I can monitor the jobs easily through the tools. Borg really saves the time for us to deploy the job and provides us rich information for us to track our applications and debug them.


---- 


# 3 Google Omega

Omega是Mesos的继任者，事实上，是同一作者。

## 3.1 Character
Omega让资源邀约更进一步。在Mesos中，资源邀约是悲观的或独占的。如果资源已经提供给一个应用程序，同样的资源将不能提供给另一个应用程序，直到邀约超时。在Omega中，资源邀约是乐观的。每个应用程序可以请求群集上的所有可用资源，冲突在提交时解决。Omega的资源管理器基本上只是一个记录每个节点状态的关系数据库，使用不同类型的乐观并发控制解决冲突。

他们的应用大致只分为两种优先级：高优先级的服务性作业（如HBase、web服务器、长住服务等）和低优先级的批处理作业（MapReduce和类似技术）。应用程序可以抢占低优先级的作业，并且在协作执行限制的范围＃内授信，以提交作业、计算资源分配等。

* **benefits** 大大增加了调度器的性能（完全并行）和更好的利用率。
* **shortcoming** 应用程序是在一个绝对自由的环境中，他们可以以最快的速度吞噬他们想要的资源，甚至抢占其他用户的资源。

## 3.2 Performance & Notice
* 服务性作业都较大，对（跨机架的）容错有更严格的配置需求。
* 由于在分配完全群集状态上的开销，Omega大概可以将调度器扩展到十倍，但是无法达到百倍。
* 秒级的调度时间是典型的。他们还比较了十秒级和百秒级的调度，这是两级调度的好处真正发挥作用的地方。无法确定这样的场景有多普遍，也许是由服务性作业来决定？
* 典型的集群利用率约为60％。
* 在OCC实践中，冲突非常罕见。在调度器崩溃之前，他们能够将正常批处理作业上升6倍。
* 增量调度是非常重要的。组调度明显更昂贵，因为要增加冲突处理的实现。显然，大多数的应用程序可以做好增量，通过实现部分资源分配进而达到他们所需的全额资源。
* 即使执行复杂的调度器（每作业十余秒的费），Omega仍然可以在合理的等待时间内调度一个混合的作业。
* 用一个新的MapReduce调度器进行实验，从经验上说，在Omega中会非常容易。

## 3.3 Notes
Borg、Omega和Kubernetes之间一个关键的差别在于它们的API构架。

Borgmaster是一个单一的组件，它知道每一个API运作的语义。它包含了诸如关于jobs、tasks和机器的状态机器的集群管理的逻辑；它跑基于Paxos的复制存储系统用来记录master的状态。反观Omega，**Omega除了存储之外没有集中的部件，存储也是简单地汇集了被动的状态信息以及加强乐观的并行进程控制**：所有的逻辑和语义都被推进存储的client里，直接读写存储的内容。在实践中，每一个Omega的部件为了存储使用同样的客户端library，来打包或者解体数据结构、重新尝试活着加强语义的一致性。

在Omega里，client的部件互相之间是分离的，可以进化或者单独被替换（这对开源环境而言尤其重要），但中央化对加强共同语义、不变性和政策会容易很多。

---- 

# 4 Alibaba Sigma
> Sigma 是阿⾥巴巴全集团范围的 Pouch 容器调度系统。2017年是 Sigma 正式上线以来第⼀次参与双11，在双11期间成功⽀撑了全集团所有容器（交易线中间件、数据库、⼴告等⼆⼗多业务）的调配，使双11IT成本降低50%，是阿⾥巴巴运维系统重要的底层基础设施。
> 

## 4.1 什么是Sigma？
Sigma集群管理系统是阿里巴巴集团云化战略的关键系统。Sigma通过和离线任务的伏羲调度系统深度集成，突破了若干CPU、内存和网络资源隔离的关键技术，实现了在线和离线任务的混合部署。

## 4.2 Sigma的出现原因：
阿里巴巴最初做调度的时候，各个部门技术架构相对比较独立，有各自的资源池，也能够比较垂直的从上至下做一整套技术栈。不过，这样也有一个比较大的缺点：在大规模资源使用的情况下如双11，一些没有直接参与双11交易链路的资源可能比较空闲，而双11直接相关的系统又背负着较大的资源压力，资源的使用率不均衡导致资源严重浪费。所以需要一个调度系统去整合各部分资源，逻辑上要统一资源池，更充分的分配和使用各部分资源。把计算任务与在线服务进行混合部署，在现有弹性资源基础上提升集群资源利用率，降低双11资源新增成本。Sigma调度系统由此而生。

## 4.3 Characteristics

### 4.3.1 Sigma调度系统的整理架构：

下图为Sigma调度系统的整理架构，有Alikenel、SigmaSlave、SigmaMaster三层大脑联动合作。

![image](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw1/sigma/1.png)

- Alikenel部署在每一台NC上，对内核进行增强，在资源分配、时间片分配上进行灵活的按优先级和策略调整，对任务的时延，任务时间片的抢占、不合理抢占的驱逐都能通过上层的规则配置自行决策。
- SigmaSlave可以在本机上进行CPU的分配、应急场景的处理。通过本机Slave对时延敏感任务快速做出决策和响应，避免因全局决策处理时间长带来的业务损失。
- SigmaMaster是一个最强的大脑，它可以统揽全局，为大量物理机的容器部署进行资源调度分配和算法优化决策。

### 4.3.2 混合部署：
 

阿里通过调度集群管理系统，实现资源的效率的提升，这里有一个非常关键的技术叫做混部。将一种对于资源的使用可以随时去避让的业务如计算任务，和一种对资源使用要求很高的延时敏感的任务如在线服务部署在一起。当发生紧急情况时，将资源分配给对延时敏感的紧急任务，实现资源的有效分配。

> “在线服务的容器就像砖块，而计算任务就像沙子和水。当在线服务压力小的时候，计算任务就占住那些空隙，把空闲的资源都使用起来，而当在线服务忙的时候，计算任务便立即退出空隙，把资源还给在线服务。”

下图为阿里基于Sigma与Fuxi混布架构：

![image](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/hw1/master/hw1/sigma/2.png)

在线服务属于长生命周期、规则策略复杂性高、时延敏感类任务。而计算任务生命周期短、调度要求大并发高吞吐、任务有不同的优先级、对时延不敏感。基于这两种调度的本质诉求的不同，我们在混合部署的架构上把两种调度并行处理，即一台物理机上可以既有 Sigma 调度又有 Fuxi 调度，实现基础环境统一。Sigma 调度是通过 SigmaAgent 启动 PouchContainer 容器。Fuxi 也在这台物理机上抢占资源，启动自己的计算任务。所有在线任务都在 PouchContainer 容器上，它负责把服务器资源进行分配并运行在线任务，离线任务填入其空白区，保证物理机资源利用达到饱和，这样就完成了两种任务的混合部署。

### 4.4 Pros：
- 通过混部，系统在平时可以极大地提升服务器资源利用率：而在双 11 这样的大促活动需要突增在线服务能力的时候，又可以通过在线服务占用计算任务资源的方式，来顶住短暂的超高峰值压力。混布之后在线机器的平均资源利用率从之前的10%左右提高到了现在的40%以上，并且同时保证了在线服务的SLO目标。
 
![image](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw1/sigma/3.png)

- 复杂约束下的批量调度优化：调度主要在竞争之前，通过资源画像，尽量减少资源竞争的可能性；提高了在线任务调度优先级。对应用的内存、CPU、网络、磁盘和网络 I/O 容量进行画像，知道它的特征、资源规格需求，不同的时间对资源真实使用情况，然后对整体规格和时间进行相关性分析，进行整体调度优化。

- 内核在发生资源竞争的极端情况时，优先保障高优先级任务。
解决了在 / 离线超线程资源争抢问题。 
在内存隔离上，拥有 CGroup 隔离 /OOM 优先级；Bandwidth Control 减少离线配额实现带宽隔离。
在内存弹性上，在内存不增加的情况下，提高混部效果，在线闲置时离线突破 memcg limit；需要内存时，离线及时释放。

- 精确高水位排布
不同的场景有不同的策略，双 11 的策略是稳定优先，稳定性优先代表采用平铺策略，把所有的资源用尽，让资源层全部达到最低水位。日常场景需要利用率优先，“利用率优先” 指让已经用掉的资源达到最高水位，空出大量完整资源做规模化的计算。

![image](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw1/sigma/4.png)

- 大规模快速建站：日常扩容仅预热基础镜像；
大促建站预热基础镜像；
大促建站针对性预热最热门的应用镜像；
大促建站针对独占资源池:指定具体的应用,提前镜像预热。

### 4.5 Cons
-  在大规模快速建站方面，阿里一方面将一些热门应用的镜像提前预热，但是某些时候宿主机的磁盘容量较小，而阿里的富容器镜像又比较大，当一次一键建站应用种类过多时，如果全部镜像种类都预热到对应机器上，那么磁盘是不够用的。
-  生产环境场景比较丰富，可能出现一些在测试环境下未曾预测到的场景，出现一些预期外的问题。
- 闭源
- 资源利用率比不上borg

### 4.6 My comment

近10年移动互联网、互联网+的浪潮，使互联网技术渗透到各行各业，渗透到人们生活的方方面面，这带来了互联网服务规模和数据规模的大幅增长，日益增长的服务规模和数据规模带来数据中心的急剧膨胀。Sigma 调度把服务器资源进行分配并运行在线任务，离线任务填入其空白区，保证物理机资源利用达到饱和，大幅度提高了CPU 的平均利用率，降低整个行业的IT成本，可以带来非常可观的成本节约，加速整个行业的创新发展。 


### 4.7 Reference


1. [《史无前例开放！阿里内部集群管理系统Sigma混布数据》](https://mp.weixin.qq.com/s/4-7LLacEksMGfw6eZPz53w?spm=a2c4e.11153940.blogcont196244.12.beec394fkfGVqV)  

2. [《阿里巴巴 Sigma 调度和集群管理系统架构详解》](http://blog.51cto.com/13778063/2155360?source=dra)  

3. [《想了解阿里巴巴的云化架构 看这篇就够了》](http://www.infoq.com/cn/news/2017/12/Cloud-Sigma-Pouch-Alibaba)  

4. [《如何提升集群资源利用率？ 阿里容器调度系统Sigma 深入解析》](https://www.cnblogs.com/qwangxiao/p/8719513.html)  

5. [《阿里决战双11核心技术揭秘——混部调度助力云化战略再次突破》](https://www.leiphone.com/news/201711/HHa8Y9tPeVgB1Kt8.html)  

6. [《Sigma调度与集群管理系统介绍》](http://www.doc88.com/p-7009180649046.html)




