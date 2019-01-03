# 搭建K8S集群

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

```
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
yum makecache
```
### 关闭防火墙
防火墙一定要提前关闭，否则在后续安装K8S集群的时候是个trouble maker。执行下面语句关闭，并禁用开机启动：

```
[root@localhost ~]# systemctl stop firewalld & systemctl disable firewalld
[1] 10341
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
```
### 关闭Swap
- 编辑/etc/fstab，注释掉包含swap的那一行即可，重启后可永久关闭。
或直接执行:
```
sed -i '/ swap / s/^/#/' /etc/fstab
```
关闭成功后，使用top命令查看，如下图所示表示正常：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/1.png?raw=true)

### 安装Docker

```
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache
```

```
yum install docker-ce -y
```

---

##### 也可以安装制定版本的docker：

查询可用版本

```
yum list docker-ce --showduplicates | sort -r
```
安装制定版本
```
sudo yum install docker-ce-18.03.1.ce-1.el7.centos
```
##### 如果安装错版本需要卸载重装，卸载docker
列出你安装过的包

```
$ yum list installed | grep docker
docker-engine.x86_641.7.1-1.el7 @/docker-engine-1.7.1-1.el7.x86_64.rpm
```
删除安装包

```
sudo yum -y remove docker-engine.x86_64
```
删除镜像/容器等

```
$ rm -rf /var/lib/docker
```

---
继续

查询docker版本
```
docker --version
```

### 启动Docker
启动Docker服务并激活开机启动：

```
systemctl start docker & systemctl enable docker
```
运行一条命令验证一下：

```
docker run hello-world
```

## 3、安装Kubernetes
### 配置K8S的yum源
官方仓库无法使用，建议使用阿里源的仓库，执行以下命令添加kubernetes.repo仓库：

```
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

```
setenforce 0
```

### 安装K8S组件
参考教程里面的命令没有指定版本，下载的都是最新版，和我们拿到的镜像不兼容，所以这里我们需要指定版本下载。

执行以下命令安装kubelet、kubeadm、kubectl：
```
yum install -y kubelet-1.10.0-0 kubectl-1.10.0-0 kubeadm-1.10.0-0
```

### 配置kubelet的cgroup drive
确保docker 的cgroup drive 和kubelet的cgroup drive一样：

```
docker info | grep -i cgroup

cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```
若显示不一样，则执行：

```
sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
```

### 启动kubelet

```
systemctl enable kubelet && systemctl start kubelet
```

### 下载K8S的Docker镜像

因为不能直接访问Google下载镜像所以我们只能提前下载导入镜像

地址：https://pan.baidu.com/s/11AheivJxFzc4X6Q5_qCw8A

密码：2zov

下载压缩包解压导入虚拟机，运行脚本导入镜像

```
./docker_images_load.sh
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
编辑 /etc/hostname ``` vi /etc/hostname ```
将文件内容修改为``` k8s-node1 ```

编辑/etc/hosts，``` vi /etc/hosts ```

追加内容 ``` 192.168.5.134 k8s-node1 ```
以上IP为自己的网卡2的ip地址，修改后重启生效。另外两个节点修改同理，主机名分别为
``` k8s-node2 ```、``` k8s-node3 ```。

## 5、创建集群
### 创建集群
在Master主节点（k8s-node1）上执行:

```
kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.10.0 --apiserver-advertise-address=192.168.5.134
```
> 含义：
- 1.选项--pod-network-cidr=192.168.0.0/16表示集群将使用Calico网络，这里需要提前指定Calico的子网范围
- 2.选项--kubernetes-version=v1.10.0指定K8S版本，这里必须与之前导入到Docker镜像版本v1.10.0一致，否则会访问谷歌去重新下载K8S最新版的Docker镜像
- 3.选项--apiserver-advertise-address表示绑定的网卡IP，这里一定要绑定前面设置的k8s-node1的网卡
- 4.若执行kubeadm init出错或强制终止，则再需要执行该命令时，需要先执行kubeadm reset重置

执行结果：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/4.png?raw=true)

可以看到，提示集群成功初始化，并且我们需要执行以下命令：

```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
### 创建网络
在主节点上，需要执行如下命令：

```
kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
```

执行
```
kubectl get pod -n kube-system
```
查看状态

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/5.png?raw=true)

## 6、集群设置
### 将Master作为工作节点

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

于是我们可以创建一个单节点的K8S集群

执行结果：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/6.png?raw=true)

执行
``` kubectl get nodes ```
查看节点

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/7.png?raw=true)

之前init的时候有给join语句

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/8.png?raw=true)

复制，在node2和node3执行：

```
kubeadm join 192.168.5.134:6443 --token 7kgabq.wcmyza9xu5o0jfcn --discovery-token-ca-cert-hash sha256:3af4e9c89993f3930b51c7b21a8f7986bb132468f075cba62ebfb9f8d0308326
```
加入集群,执行结果：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/9.png?raw=true)

在主节点执行
``` kubectl get nodes ```
查看节点

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/10.png?raw=true)

有一个not ready,稍等一下

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/11.png?raw=true)


最后检查一下查看所有pod状态，运行``` kubectl get pods -n kube-system ```：

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/12.png?raw=true)

如上，全部Running则表示集群正常。至此，我们的K8S集群就搭建成功了。

## 7.dashboard
### 下载kubernetes-dashboard.yaml
原教程里的 [下载链接](https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml/)
已经404了

这是找的[新下载链接](https://github.com/gh-Devin/kubernetes-dashboard/blob/master/kubernetes-dashboard.yaml)

### 安装dashboard
#### 1.导入镜像
###### 下载镜像

链接：https://pan.baidu.com/s/11AheivJxFzc4X6Q5_qCw8A  密码：2zov

###### 导入镜像：
```
docker load < k8s.gcr.io#kubernetes-dashboard-amd64.tar
```
![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/13.png?raw=true)

#### 2.创建Dashboard
导入镜像后，使用之前下载的yaml文件即可创建Dashboard：

```
kubectl create -f kubernetes-dashboard.yaml
```
![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/14.png?raw=true)

#### 3.访问Dashboard
执行
```
ubectl proxy --address=192.168.5.134 --disable-filter=true
```
![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/15.png?raw=true)

执行
```
kubectl get services --namespace kube-system
```
![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/16.png?raw=true)

访问
[10.106.158.105:9090](10.106.158.105:9090)得到以下界面

![image](https://github.com/199ChenNuo/grade3-semester1-homework/blob/master/hw4/part2/img/17.png?raw=true)

dashboard部署成功，运行成功。
