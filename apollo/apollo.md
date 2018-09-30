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
  
  
Apollo architecture overview  
![Apollo Architectura Overview](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Apollo-Architectural-Overview.png) 

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

## 3 Pros & Cons  

### 3.1 pros

1. **High** aggregated scheduling rate at Scale  
Apollo can constantly provide a scheduling rate of above 10,000, reaching up to 20,000 per second in a single cluster.  
Apollo at production  
![Apollo At Production](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Comparision-Between-Apollo-And-The-Baseline-Scheduler.png)  

 
2. **High** Scheduling Quality  
Apollo delivers excellent job performance compared with the baseline scheduler and its scheduling quality is close to the optimal case.   
comparision between Apollo and the baseline scheduler  
![comparision between Apollo and the baseline scheduler](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Apollo-At-Production.png)  


3. Helpful and accurate **Evaluating Estimates**  
. Apollo provides good estimates on task wait time and CPU time, despite all the challenges, and estimation does help improve scheduling quality.  
how Estimates helps Apollo to do better job   
![Scheduling-Balance](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Scheduling-Balance.png)  

4. Correction Effectiveness  
| Conditions (W: wait time) | Trigger rate | Success rate |  
| :-: | :-: | :-: |  
| New expected W significantly higher | 0.12% | 81.3% |  
| Expected W greater than average | 0.12% | 81.3% |  
| Elaspsed W greater than average | 0.17% | 83.0% |


5. **Stable** Matching Efficiency  
Apollo’s matching algorithm has the same asymptotic complexity as a naive greedy algorithm with negligible overhead. It performs significantly better than the greedy algorithm and is within 5% of the optimal scheduling in our simulation.  
![Matching-quality](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Matching-Quality.png)  

### 3.2 cons  

1. **must** work with stale information (unlike a centralized scheduler)  

2. may experience **degraded scheduler performance** under high contention  
(although this can apply to other architectures as well).  

3. not open sourced  


## 4 My comments  
Apollo can achieve high utilization and low latency, while coping well with the dynamics in diverse workloads and large clusters. It is a ideal solution for schale sheduleing. Notice that Apollo has already been deployed in production, its profermance can be guaranteed. However, Apollo is closed, not like open-source Kubernetes.

## 5 Conculsion  
- different cluster scheduler architectures  
![different cluster scheduler architectures](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Different-Cluster-Scheduler-Architectures.png)  

- architectures classifaction and feature matrix  
![architecture classifcation and feature matrix](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Architecture-Classifaction-And-Feature-Matrix.png)  


## 6 reference  
1. [Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing (paper)](https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-boutin_0.pdf)  
2. [Presetation for Apollo](https://www.usenix.org/conference/osdi14/technical-sessions/presentation/boutin)  
3. [【每周论文】Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing](https://blog.csdn.net/violet_echo_0908/article/details/78174782)  
4. [The evolution of cluster scheduler architectures](https://www.cl.cam.ac.uk/research/srg/netos/camsas/blog/2016-03-09-scheduler-architectures.html)