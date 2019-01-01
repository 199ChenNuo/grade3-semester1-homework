# container  
- image （镜像）  
`镜像可以用来创建docker容器`
    - bluiding
        - CI/CD

- Kubernetes
    - Architecture
    - Objects
    - Features*  
    可以做的feature：Auto-Scaling  
    `可感知的服务压力`
    - Scheduling*

- Monitoring & Tracing  
    - Collector
        - Logs
        - Metrics
    - Visualization  

----

# 作业要求  
`每个组除了交代码之外，要去找任爹演示一遍`
1. Requirement 1
    1. Prepare a CI/CD environment  
    `云服务&另外的机器&后面的要求所在的机器`
        - Deliverables
            - Markdown
            - Demo 
    1. Prepare a web application, build container images  
        - Application
            - front-end & back-end & database
        - Deliverables
            - Demo
            - Markdown
    1. Automatically build images after a PR
        - Demo
        - Markdown
1. Requirement 2  
`翻墙`
    1. Prepare a Kubernetes envirnoment
        - Mode
            - single Host
                - snap
            - **Cluster**
                - Kubeadm
        - Features
            - DNS
            - Dashboard
        - Deliverables
            - Demo
            - Markdown
1. Requirements 3  
`正常的跑起来，让外面的人可以访问`
    1. Deploy your web application on Kubernetes
        - Expose your web application  
        `不能被集群外的人访问到，要创建一个service让外面的人访问到。`  
        `前端后端在一起的话，创建一个service就可以。`  
        - Deliverables
            - Demo
            - Deployment yaml
            - Markdown
1. Requirement 4
    1. Load balance  
    `实例个数不同时的不同表现`  
    `放多少实例可以满足多大的要求`  
    `做实验画个图，随着压力增大，response time的变化`
        - Front-end & Back-end
    1. Experiment
        - Measure the RPS of different scale
    1. Deliverable
        - Demo
        - Experiment report in markdown
    
----

# submission

1. code deadline: 2019/01/07  
1. pre deadline: 2019/01/09
        
----

# Interview

主考官期望的是，面试者与其交流（多问问题，把面试题的隐藏条件、细节问清楚）  
