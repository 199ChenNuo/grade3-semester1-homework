# kubernetes安装时遇到的一些问题

1. minikube不支持docker18.09版  
[minikube issue#3323](https://github.com/kubernetes/minikube/issues/3323)  
解决办法： 将docker降到指定版本。目前minikube支持的最新版本为18.06.1  

降版本教程：[install a specific version of docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce-1)  
```bash
# 查看可用版本
$ apt-cache madison docker-ce

 docker-ce | 5:18.09.0~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/edge amd64 Packages
 docker-ce | 18.06.1~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/edge amd64 Packages
 docker-ce | 18.06.0~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/edge amd64 Packages
 docker-ce | 18.05.0~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/edge amd64 Packages
 docker-ce | 18.03.1~ce~3-0~ubuntu | https://download.docker.com/linux/ubuntu bionic/edge amd64 Packages

```

```bash
# 选择18.06 （版本号为18.06.1~ce~3-0~ubuntu)
$ sudo apt install docker=18.06.1~ce~3-0~ubuntu
```

2. 端口被占用  
[kubeadm issue#339](https://github.com/kubernetes/kubeadm/issues/339)  
原因：kubeadm原有线程没有清除干净

解决办法：reset kubeadm
```bash
$ su
password:xxxx
[root]$ kubeadm reset
```

3. VirutalBox不支持在虚拟机内部再开虚拟机  
VT-x/AMD-v报错。  
```bash
This computer doesn't have VT-X/AMD-v enabled. Enabling it in the BIOS is mandatory.
```
解决办法：  
    1. 在BIOS中更改设置
    2. 启动minikube时指定不使用虚拟机  
```bash
$ sudo minikube start --vm-driver=none
```

---

# 配置yaml  

在/root/nora/web-yaml/下创建以下文件  
```
.  
├── mysql-dm.yaml  
├── mysql-svc.yaml  
├── frontend-dm.yaml  
├── frontend-svc.yaml  
├── backend-dm.yaml  
└── backend-svc.yaml  
```
以`mysql-dm.yaml`和`mysql-svc.yaml`为例说明  

mysql-dm-yaml:
```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        ports:
        - containerPort: 3306 
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "123456"
```

mysql-svc-yaml:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  ports:
  - port: 3306
  selector:
    app: mysql
```
将部署mysql在kubernetes中的一个pod，使用Service向内部暴露端口3306。  
前端、后端的配置类似于mysql配置  

---

# 部署
使用下面的命令来部署。 `deployment.yaml`用上面写好的yaml文件取代
```shell
$ kubectl create -f deployment.yaml
```

使用下面的命令来新建Service。`service.yaml`用上面写好的xxx-scv.yaml代替  
```shell
$ kubectl create -f service.yaml
```

---

# 负载均衡

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-node-service-lb
  labels:
    name: kube-node-service-lb
spec:
  type: LoadBalancer
  clusterIP: 10.99.201.198
  ports:
  - port: 80
    targetPort: 8081
    protocol: TCP
    nodePort: 32145
  selector:
    app: web
status:
  loadBalancer:
    ingress:
    - ip: 192.168.174.127
```
同样使用
```shell
$ kubectl create -f service.yaml
```
来创建service  
