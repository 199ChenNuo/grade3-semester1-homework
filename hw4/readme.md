# part1.

## 1. Prepare a CI/CD environment  

Frontend repo:[https://github.com/myuaggie/eatornot_frontend](https://github.com/myuaggie/eatornot_frontend)  

Backend repo:[https://github.com/myuaggie/eatornot_backend](https://github.com/myuaggie/eatornot_backend)  

Use Jenkins in docker image to do CI/CD.
1. Download Jenkins image.
```shell
$ docker pull jenkins/jenkins:lts
```

2. Run container.
``` shell
$ docker run --name jenkins7 -p 8087:8080 -p 50007:50000 --privileged=true -v /usr/local/bin/docker:/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -d jenkins/jenkins:lts
```
Mount the host's docker cmd to the container.(optional)

3. Use localhost:8087 to config Jenkins.

### 1.1 CI/CD Frontend
4. Set automatic Nodejs installations in the global tool configuration.

5. Config New Job.  
Choose “创建一个自由风格的软件项目”   
-> Config Github URL   
-> Config Build Trigger(SCM)   
-> Config Build Environment(Provide Node & npm bin/ folder to PATH)  
-> Config Build(execute shell: npm install; npm run build)
![frontend package result](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw4/part1/img/frontendbuild.png)

### 1.2 CI/CD Backend
6. Set java_home in the global tool configuration.
/usr/lib/jvm/java-8-openjdk-amd64

7. Install Maven Integration Plugin in Jenkins.

8. Get into docker container and Download Maven, config maven's path in the global tool configuration.  
```shell
$ docker exec -it <container-id> /bin/bash
$ wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
$ tar zxvf apache-maven-3.3.9-bin.tar.gz
```

9. Config New Job.
Choose “Create Maven Project”   
-> Config Github URL  
-> Config Build Trigger(SCM)  
-> Config Build(Goals and options: clean package)
![backend package result](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw4/part1/img/backendbuild.png)

## 2. Prepare a web application build container images

Use Eat or Not as the example web application with react frontend, springboot backend and mysql database.

### 2.1 Frontend
Use nginx to run react frontend.
1. Download nginx image 
```shell
$ docker pull nginx
```

2. Package frontend code
```shell
$ npm build
```
3. Create and edit **docker-compose.yml** to config docker-compose which automatically create and run container.
services:nginx:image configs the image to run.
services:nginx:port maps container's port to localhost port.
services:nginx:volumes: maps local's build folder to container's default static resource folder **/usr/share/nginx/html**.

4. Create and edit nginx.conf to support react-router.

5. Create and run contianer
```shell
$ docker-compose up -d
```

### 2.2 Database
1. Download mysql image.(To avoid that cersion is not compatible, download the version which is same as the local one)
```shell
$ docker pull mysql:5.7
```

2. Run image
```shell 
$ docker run -name mysqleatornot -e MYSQL_ROOT_PASSWORD=123456 -p 3306:3306 -d mysql:5.7
```

3. Get into container
```shell
$ docker exec -it mysqleatornot /bin/bash
```

4. Get into mysql
```shell
$ mysql -u root -p 123456
```

5. Config authorization for remote login
```shell
$ ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
$ FLUSH PRIVILEGES;
```

6. Use MySQL Workbench to create schema and import data into the container

### 2.3 Backend
1. Add maven's plugin **docker-maven-plugin** in pom.xml.

2. Use **maven package** to package the project => docker_spring_boot.jar (final name is configed in pom.xml).

3. Create and edit **Dockerfile**.
FROM: configs the image to run.
VOLUME: configs the mount path.
ADD: mounts the docker_spring_boot.jar as the app.jar in container.
ENTRYPOINT: configs the command line executed when running. 

4. Cd to the folder with **Dockerfile** and **docker_spring_boot.jar** then build the image.
```shell
$ docker build -t springboot/eatornot .
```

5. Run the image and link to the mysql container.
``` shell
$ docker run -d -p 8080:8080 --link mysqleatornot:db springboot/eatornot
```
link maps mysqleatornot container's port to springboot/eatornot's and use db as alias in the container.
So changes the connection configuration in hibernate.cfg.xml(use the alias **db** instead of localhost):
```xml
<property name="connection.url">jdbc:mysql://db:3306/SummerProj?characterEncoding=UTF-8</property>
```

## 3. Automatically build images after a PR

1. Install publish over SSH plugin in Jenkins

2. Get into docker container and generate public key and private key.
```shell
$ ssh-keygen
```

3. Copy public key(in /var/jenkins_home/.ssh/id_rsa.pub) into host's autherauthorized_keys.

4. Config Publish over SSH in Jenkins system settings, set **Path to key** as /var/jenkins_home/.ssh/id_rsa.

5. Add SSH Server.(I use my own pc as the SSH server.)

6. Run a private docker registry.
``` shell
$ docker run -itd -p 5000:5000 -v <some_host_path>:/var/lib/registry --name registry registry:2.5
```

7. Set **insecure registries**([your_ip]:5000) in Docker‘s Daemon Setting.

### 3.1 Frontend
Add Post-build Actions: send build artifacts over SSH:
Transfer the **build** folder, **docker-compose.yml**, **nginx.conf** to a specific directory in the server.
Exec command：
``` shell
$ cd <full remote directory path>
$ /usr/local/bin/docker-compose down
$ /usr/local/bin/docker-compose up -d
```
![frontend build image result](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw4/part1/img/frontenddocker.png)

### 3.2 Backend
Add Post-build Actions: send files or execute commands over SSH:
Transfer the jar package in target folder built by maven.
Exec command（docker.sh is the shell script in my remote server:
```shell
$ cd <full remote directory path>
$ sh docker.sh $BUILD_NUMBER $GIT_COMMIT
```
The main content in docker.sh:
1. Stop and delete old container.
``` shell
$ /usr/local/bin/docker stop $CONTAINER_NAME
$ /usr/local/bin/docker rm $CONTAINER_NAME
$ /usr/local/bin/docker rmi -f $IMAGE_ID
```
2. Build docker image by Dockerfile（Dockerfile can be in the server or sent by SSH).
``` shell
$ /usr/local/bin/docker build --build-arg app=$JARNAME .  -t  $IMAGES_NAME:$BUILD_ID
```
3. Run container based on the built image.
```shell 
$ /usr/local/bin/docker run -itd -p 8080:8080 --name $CONTAINER_NAME --link mysqleatornot:db $IMAGES_NAME:$BUILD_ID
```
4. Commit image to private docker registery.
``` shell
$ /usr/local/bin/docker tag $IMAGES_NAME:$BUILD_ID <host_ip>:5000/$IMAGES_NAME:$BUILD_ID
$ /usr/local/bin/docker push <host_ip>:5000/$IMAGES_NAME:$BUILD_ID
```
![backend build image result](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw4/part1/img/backenddocker.png)

## 4. Result
### 4.1 Containers
![containers](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw4/part1/img/containers.png)

### 4.2 CI/CD Results
![cicdresult](https://raw.githubusercontent.com/199ChenNuo/grade3-semester1-homework/master/hw4/part1/img/cicdresult.png)

----

# part 2. Prepare a Kubernetes environment  

[参考教程](https://www.jianshu.com/p/78a5afd0c597)

## 1、虚拟机环境

参考教程里用的VirtualBox，之前也尝试了用VirtualBox，但是感觉不是很好用。然后我之前都是用的VMware，比较熟悉一点，所以最后用的VMware。

- 虚拟机：VMware Workstation 15 Player
- 操作系统镜像：CentOS-7-x86_64-DVD-1708.iso
- 操作系统 CentOS 7.4
- 内存 2G 
- CPU 2核
- 硬盘 20G 

## 2、设置环境

### 配置yum源

不建议使用CentOS 7 自带的yum源，因为安装软件和依赖时会非常慢甚至超时失败。这里，我们使用阿里云的源予以替换

```shell
$ wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
$ yum makecache
```
### 关闭防火墙
防火墙一定要提前关闭，否则在后续安装K8S集群的时候是个trouble maker。执行下面语句关闭，并禁用开机启动：

```shell
[root@localhost ~]# systemctl stop firewalld & systemctl disable firewalld
[1] 10341
$ Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
$ Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
```
### 关闭Swap
- 编辑/etc/fstab，注释掉包含swap的那一行即可，重启后可永久关闭。
或直接执行:
```shell
$ sed -i '/ swap / s/^/#/' /etc/fstab
```
关闭成功后，使用top命令查看，如下图所示表示正常：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/1.png?raw=true)

### 安装Docker

```shell
$ yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
$ yum makecache
```

```shell
$ yum install docker-ce -y
```

---

##### 也可以安装制定版本的docker：

查询可用版本

```shell
$ yum list docker-ce --showduplicates | sort -r
```
安装制定版本
```shell
$ sudo yum install docker-ce-18.03.1.ce-1.el7.centos
```
##### 如果安装错版本需要卸载重装，卸载docker
列出你安装过的包

```shell
$ yum list installed | grep docker
docker-engine.x86_641.7.1-1.el7 @/docker-engine-1.7.1-1.el7.x86_64.rpm
```
删除安装包

```shell
$ sudo yum -y remove docker-engine.x86_64
```
删除镜像/容器等

```shell
$ rm -rf /var/lib/docker
```

---
继续

查询docker版本
```shell
$ docker --version
```

### 启动Docker
启动Docker服务并激活开机启动：

```shell
$ systemctl start docker & systemctl enable docker
```
运行一条命令验证一下：

```shell
$ docker run hello-world
```

## 3、安装Kubernetes
### 配置K8S的yum源
官方仓库无法使用，建议使用阿里源的仓库，执行以下命令添加kubernetes.repo仓库：

```vim
cat <<EOF > /etc/yum.repos.d/kubernetes.repo

[kubernetes]

name=Kubernetes

baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64

enabled=1

gpgcheck=0

repo_gpgcheck=0

gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg

        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg

EOF
```
### 关闭SeLinux

```shell
$ setenforce 0
```

### 安装K8S组件
参考教程里面的命令没有指定版本，下载的都是最新版，和我们拿到的镜像不兼容，所以这里我们需要指定版本下载。

执行以下命令安装kubelet、kubeadm、kubectl：
```shell
$ yum install -y kubelet-1.10.0-0 kubectl-1.10.0-0 kubeadm-1.10.0-0
```

### 配置kubelet的cgroup drive
确保docker 的cgroup drive 和kubelet的cgroup drive一样：

```shell
$ docker info | grep -i cgroup

$ cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```
若显示不一样，则执行：

```shell
$ sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
$ systemctl daemon-reload
```

### 启动kubelet

```shell
$ systemctl enable kubelet && systemctl start kubelet
```

### 下载K8S的Docker镜像

因为不能直接访问Google下载镜像所以我们只能提前下载导入镜像

地址：https://pan.baidu.com/s/11AheivJxFzc4X6Q5_qCw8A

密码：2zov

下载压缩包解压导入虚拟机，运行脚本导入镜像

```shell
$ ./docker_images_load.sh
```

运行```docker images```
运行结果如下，其中dashboard的镜像在后面导入，暂时是不会有那个的。

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/2.png?raw=true)


## 4、复制虚拟机
如果我们需要多节点，需要配置几个一样的虚拟机，可以复制现在已经配好的这个虚拟机。

### 复制方法：
VMware workstation pro的复制很方便，直接就有克隆选项，原教程里有vitrualBox的克隆教程，如果是player没有克隆选项：
- 先把配好的虚拟机关机。
- 找到工作目录：管理-虚拟机设置-选项-工作目录
- 把工作目录整个复制一遍，找个新目录粘贴
- 打开VMware，点击打开虚拟机，找到刚才粘贴的目录，打开.vmx的格式的文件。
- 然后配置网卡
 
#### 配置网卡：
- 管理-虚拟机设置-硬件-添加-网络适配器-网络连接选择仅主机模式-确定

然后开机就可以了。

在各个虚拟机上运行
```
ip addr
```
可以查询ip地址

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/3.png?raw=true)

和其他虚拟机的ip地址互相ping一下，确保网络连通正常。
这是我的地址：
- node1:192.168.5.134
- node2:192.168.5.136
- node3:192.168.5.138
- 
### 设置虚拟机
编辑 /etc/hostname 
``` shell
$ vi /etc/hostname 
```
将文件内容修改为``` k8s-node1 ```

编辑/etc/hosts，
``` shell
$ vi /etc/hosts 
```

追加内容 ``` 192.168.5.134 k8s-node1 ```
以上IP为自己的网卡2的ip地址，修改后重启生效。另外两个节点修改同理，主机名分别为
``` k8s-node2 ```、``` k8s-node3 ```。

## 5、创建集群
### 创建集群
在Master主节点（k8s-node1）上执行:

```shell
$ kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.10.0 --apiserver-advertise-address=192.168.5.134
```
> 含义：
- 1.选项--pod-network-cidr=192.168.0.0/16表示集群将使用Calico网络，这里需要提前指定Calico的子网范围
- 2.选项--kubernetes-version=v1.10.0指定K8S版本，这里必须与之前导入到Docker镜像版本v1.10.0一致，否则会访问谷歌去重新下载K8S最新版的Docker镜像
- 3.选项--apiserver-advertise-address表示绑定的网卡IP，这里一定要绑定前面设置的k8s-node1的网卡
- 4.若执行kubeadm init出错或强制终止，则再需要执行该命令时，需要先执行kubeadm reset重置

执行结果：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/4.png?raw=true)

可以看到，提示集群成功初始化，并且我们需要执行以下命令：

```shell
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### 创建网络
在主节点上，需要执行如下命令：

```shell
$ kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
```

执行
```shell
$ kubectl get pod -n kube-system
```
查看状态

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/5.png?raw=true)

## 6、集群设置
### 将Master作为工作节点

```shell
$ kubectl taint nodes --all node-role.kubernetes.io/master-
```

于是我们可以创建一个单节点的K8S集群

执行结果：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/6.png?raw=true)

执行
``` shell
$ kubectl get nodes 
```
查看节点

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/7.png?raw=true)

之前init的时候有给join语句

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/8.png?raw=true)

复制，在node2和node3执行：

```shell
$ kubeadm join 192.168.5.134:6443 --token 7kgabq.wcmyza9xu5o0jfcn --discovery-token-ca-cert-hash sha256:3af4e9c89993f3930b51c7b21a8f7986bb132468f075cba62ebfb9f8d0308326
```
加入集群,执行结果：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/9.png?raw=true)

在主节点执行
``` shell
$ kubectl get nodes 
```
查看节点

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/10.png?raw=true)

有一个not ready,稍等一下

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/11.png?raw=true)


最后检查一下查看所有pod状态，运行
``` shell
$ kubectl get pods -n kube-system 
```

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/12.png?raw=true)

如上，全部Running则表示集群正常。至此，我们的K8S集群就搭建成功了。