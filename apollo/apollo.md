# Scalable and Coordinated Scheduling for Cloud-Scale Computing: Apollo  

<center>Eric Boutin, Jaliya Ekanayake, Wei Lin, Bing Shi, and Jingren Zhou,</center> 
<center>Microsoft;  </center>
<center>Zhengping Qian, Ming Wu, and Lidong Zhou,  </center>
<center>Microsoft Research  </center>

## 1. Microsoft needs a schedular that:
* scale to make tens of thousands of scheduling decisions per second on a cluster with tens of thousands of servers;  
* maintain fair sharing of resources among different users and groups;  
* make high-quality scheduling decisions that take into account factors such as data locality, job characteristics, and server load, to minimize job latencies while utilizing the resources in a cluster fully.  

## 2. Apollo characteristic:  
### 2.1 Architectual 
**Job Manager (JM)** is a scheduler that is responsable for scheduling jobs. Each cluster has a Resource **Monitor (RM)** and each server has a **Process Node (PN)**.  
RM and PN coordinate to provide a global view for the JM to reference when making scheduling decisions. Each PN is responsible for managing the resources from local server. RM collect information from PN, then generate the global information and give it to each JM.  
[Apollo Architectura Overview](url)  

### 2.2 Characteristic  
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

## 3 Prons & Cons



## reference  
1. [Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing (paper)](https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-boutin_0.pdf)  
2. [Presetation for Apollo](https://www.usenix.org/conference/osdi14/technical-sessions/presentation/boutin)  
3. [【每周论文】Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing](https://blog.csdn.net/violet_echo_0908/article/details/78174782)