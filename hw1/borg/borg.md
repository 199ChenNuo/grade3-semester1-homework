# Large-scale cluster management system: Borg

Borg admits, schedules, starts, restarts, and monitors the full range of applications that Google runs.

Main benefits:
* hides the details of resource management and failure handling.
* operates with very high reliability and availability, and supports applications do the same.
* run workloads across tens of thousands of machines effectively.


## Architecture
![borg architecture](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/borg/borg%20architecture.png?raw=true)
A borg cell consists of a set of machines, a logically centralized controller called the Borgmaster, and an agent process called the Borglet thtat runs on each machine in a cell.

### Basic Workflow: 
* Users configs and submits the job through **borgcfg**, **command-line tools** and **web browsers UI (Sigma)**.
* **Borgmaster** records it persistently in the Paxos store and adds the job's tasks to the pending queue.
* **Scheduler** scans the job and assigns tasks to machines if there are sufficient available resources that meet the job's constraints.
* **Borgmaster** sends **Borglet** request to let it start the job on the machines.

### Borgmaster
The Borgmaster handles client RPCs that either mutate state or provide read-only access to data, it also manages state machines for all of the objects in the system, communicates with the Borglets, and offers a web UI as a backup to Sigma.
The Borgmaster is logically a single process but is actually replicated five times. Each replica maintains an in-memory copy of most of the state of the cell. But there is only one elected master per cell serves both as the Paxos leader and the state mutator.
A high-fidelity Borgmaster simulator called Fauxmaster can be used to read checkpoint files, and contains a complete copy of the production Borgmaster code, with stubbed-out interfaces to the Borglets. Users can use it to debug failures by interacting with it as if it were a live Borgmaster, with simulated Borglets replaying real interactions from the checkpoint file.

### Scheduling
The scheduling algorithm has two parts: feasibility checking, to find machines on which the task chould run, and scoring, which picks one of the feasible machines.
In feasibility checking, the scheduler finds a set of machines that meet the task's constraints and also have enough available resources(includes resources can be evicted). If the machine selected doesn't have enough available resources to fit the new task, Borg preempts lower-priority tasks from lowest to highest until it does, and add the preempted tasks to the scheduler's pending queue.
The score takes into account user-specified preferences, but is mostly driven by built-in criteria:
* minimizing the number and priority of preempted tasks
* picking machines that already have a copy of the task's packages.(bottleneck: contention for the local disk where packages are written to.)
* putting a mix of high and low priority tasks onto a single machine to allow the high-priority ones to expand in a load spike.

### Borglet
The Borglet is a local Borg agent that is present on every machine in a cell.
It starts and stops tasks; restarts them if they fail; manages local resources by manipulating OS kernel settings; rolls over debug logs; reports the state of the machine to the Borgmaster and other monitoring system.
The Borgmaster polls each Borglet every few seconds to retrieve the machine's current state, thus avoiding the need for an explicit flow control mechanism and preventing recovery storms.
For performance scalability, each Borgmaster replica runs a stateless link shard to handle the communication.
For resiliency, the Borglet always reports its full state, the link shards aggregate and compress the information by reporting only differences to the state machines.

### Scalability
To handle larger cells, scheduler is splited into a separate process so it could operate in parallel with the other Borgmaster functions that are replicated for failure tolerance.
To improve response times, separate threads are added to talk to the Borglets and respond to read-only RPCs.
To make the scheduler more scalable:
* Score caching: Borg caches the scores until the properties of the machine or task change.
* Equivalence classes: Borg only does feasibility and scoring for one task per equivalence class —— a group of tasks with identical requirements.
* Relaxed randomization: Sechduler examines machines in a random order until it has found enough feasible machines to score, and then selects the best within the set. 

## Conceptions(Feature)
Users submit their work to Borg in the form of jobs, each of which consists of one or more tasks that all run the same program. Each job runs in one Borg cell, a set of machines that are managed as a unit.

### Workload
Borg cells run a heterogenous workload with two main parts:
* Long-running services(prod): producets, internal infrastructure services.
* Batch jobs(non-prod).

### Clusters & Cells
A cluster usually hosts one large cell and may have a few smaller-scale test or special-purpose cells. The machines in a cell are heterogeneous in many dimensions: size (CPU, RAM, disk, network), processor type, performance, and capabilities such as an external IP address or flash storage.

### Jobs & Tasks
A Borg job's properties include its name, owner, and the number of tasks it has. A job runs in just one cell. Each task maps to a set of Linux processes running in a container on a machine. Most task properties are the same across all tasks in a job but can be overridden. Borg programs are statically linked to reduce dependencies on their runtime environment, and structured as packages of binaries and data files, whose installation is orchestrated by Borg. Most job descriptions are written in the declarative configuration language BCL. A user can change the properties of some or all the tasks in a running job by pushing a new job configuration to Borg, then Borg will update the tasks to the new specification. Some task updates will always require the task to be restarted, some might make the task no longer fit on the machine, and cause it to be stopped and rescheduled, and some can always be done without restarting or moving the task.  
![jobs & tasks workflow](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw1/borg/job:task%20lifetime.png?raw=true)

### Allocs
A Borg alloc is a reserved set of resources on a machine in which one or more tasks can be run. Allocs can be used to set resources aside for future tasks, to retain resources between stopping a task and starting it again, and to gather tasks from different jobs onto the same machine. An alloc set is like a job which is a group of allocs that reserve resources on multiple machines. 

### Priority
Borg defines non-overlapping priority bands for different uses, including: monitoring, production, batch, and best effort(testing/free).
A high-priority task can obtain resources at the expense of a lower-priority one, high-priority task can preempt the lower-priority one. Tasks in the production priority is not allowed to preempt one another.

### Quota
Quota is used to decide which jobs to admit for scheduling. Quota is expressed as a vector of resource quantities (CPU, RAM, disk...) at a given priority, for a period of time. The quantities specify the maximum amount of resources that a user’s job requests can ask for at a time, jobs with insufficient quota will be immediately rejected upon submission.

## Utilization

### Cell Compaction
Given a workload, found out how small a cell it could be fitted into by removing machines until the workload no longer fitted, repeatedly re-packing the workload from scratch to ensure that there isn't any unlucky configuration.

### Cell Sharing
Nearly all of our machines run both prod and non-prod tasks at the same time: 98% of the machines in shared Borg cells, 83% across the entire set of machines managed by Borg. 
Prod jobs usually reserve resources to handle rare workload spikes, but don’t use these resources most of the time, so Borg can reclaim the unused resources to run much of the non-prod work.

### Large Cells
Large cells both can allow large computations to be run, and can decrease resource fragmentation. 

## Isolation

### LS tasks
To help with overload and overcommitment, Borg tasks have an appclass. Latency-sensitive (LS) tasks are used for user-facing applications and shared infrastructure services that require fast response to requests. High-priority LS tasks receive the best treatment, and are capable of temporarily starving batch tasks for several seconds at a time.

### Compressible Resources
Compressible resources are rate-based and can be reclaimed from a task by decreasing its quality of service without killing it; and non-compressible resources (e.g., memory, disk space) which generally cannot be reclaimed without killing the task. If a machine runs out of non-compressible resources, the Borglet immediately terminates tasks, from lowest to highest priority, until the remaining reservations can be met. If the machine runs out of compressible resources, the Borglet throttles usage so that short load spikes can be handled without killing any tasks.

## Drawbacks
* Jobs are restrictive as the only grouping mechanism for tasks.
 Borg has no first-class way to manage an entire multi-job service as a single entity, or to refer to related instances of a service
* One IP address per machine complicates things.
In Borg, all tasks on a machine use the single IP address of their host, and thus share the host’s port space. This causes a number of difficulties: Borg must schedule ports as a resource; tasks must pre-declare how many ports they need, and be willing to be told which ones to use when they start; the Borglet must enforce port isolation; and the naming and RPC systems must handle ports as well as IP addresses.
* Optimizing for power users at the expense of casual ones.

## Conclusion
* Borg achieves high utilization by combining admission control, efficient task-packing, over-commitment, and machine sharing with process-level performance isolation.
* Borg supports high-availability applications with runtime features that minimize fault-recovery time, and scheduling policies that reduce the probability of correlated failures. 
* Borg simplifies life for its users by offering a declarative job specification language, name service integration, real-time job monitoring, and tools to analyze and simulate system behavior.
I feel really lucky to have experience in using Borg in internal Google. I have used Borg to run some batch jobs, there are lots of other tools corporating with borg well so that a job can be easily configed without much work then everything after that is totally automated and I can monitor the jobs easily through the tools. Borg really saves the time for us to deploy the job and provides us rich information for us to track our applications and debug them.


