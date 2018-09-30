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

![Apollo Architectura Overview](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Apollo-Architectural-Overview.png) 
<center>Apollo architecture overview</center> 

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

* **High** aggregated scheduling rate at Scale  
Apollo can constantly provide a scheduling rate of above 10,000, reaching up to 20,000 per second in a single cluster.  
![Apollo At Production](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Comparision-Between-Apollo-And-The-Baseline-Scheduler.png)  
<center>Apollo at prodution</center>
 
* **High** Scheduling Quality  
Apollo delivers excellent job performance compared with the baseline scheduler and its scheduling quality is close to the optimal case.  
![comparision between Apollo and the baseline scheduler](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Apollo-At-Production.png)  
<center>comparision between Apollo and the baseline scheduler</center>

* Helpful and accurate **Evaluating Estimates**  
. Apollo provides good estimates on task wait time and CPU time, despite all the challenges, and estimation does help improve scheduling quality.  
![Scheduling-Balance](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Scheduling-Balance.png)  
<center>how Estimates helps Apollo to do better job</center>  

* Correction Effectiveness  

| Conditions (W: wait time) | Trigger rate | Success rate |  
| :-: | :-: | :-: |  
| New expected W significantly higher | 0.12% | 81.3% |  
| Expected W greater than average | 0.12% | 81.3% |  
| Elaspsed W greater than average | 0.17% | 83.0% |


* **Stable** Matching Efficiency  
Apollo’s matching algorithm has the same asymptotic complexity as a naive greedy algorithm with negligible overhead. It performs significantly better than the greedy algorithm and is within 5% of the optimal scheduling in our simulation.  
![Matching-quality](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Matching-Quality.png)  
<center>Matching quality</center>  

## 4 Conculsion  
![different cluster scheduler architectures](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Different-Cluster-Sheduler-Architectures.png)  
<center>different cluster scheduler architectures</center>  
![architecture classifcation and feature matrix](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/apollo/Architecture-Classifaction-And-Feature-Matrix.png)  
<center>architectures classifaction and feature matrix</center>


## 5 reference  
1. [Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing (paper)](https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-boutin_0.pdf)  
2. [Presetation for Apollo](https://www.usenix.org/conference/osdi14/technical-sessions/presentation/boutin)  
3. [【每周论文】Apollo: Scalable and Coordinated Scheduling for Cloud-Scale Computing](https://blog.csdn.net/violet_echo_0908/article/details/78174782)