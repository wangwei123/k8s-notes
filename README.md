# k8s-notes
k8s笔记, 自动化脚本搭建k8s集群环境

####准备三个服务器作为最小集群，1个master, 2个node，命名分别为：
k8s-master, k8s-node01, k8s-node02

####将以下文件上传到master服务器的/home目录:
install-docker.sh	
install-k8s-master.sh
kube-flannel.yml

####将以下文件上传到2个node服务器的/home目录:
install-docker.sh	
install-k8s-nodes.sh

###首先安装k8s-master环境，进入/home目录，执行如下命令步骤：
```
# 安装docker，执行如下命令
./install-docker.sh

# 修改hosts信息
vim install-k8s-master.sh

# 找到如下内容，将IP修改为你对应节点的服务器内网IP，:wq保存
#配置节点hosts
echo "###请配置节点IP和hostname到hosts文件###"
cat >> /etc/hosts << EOF
  172.19.140.157 k8s-master
  172.19.140.152 k8s-node01
  172.19.140.160 k8s-node02
EOF

# 执行脚本，安装k8s
./install-k8s-master.sh

# 注意事项
安装过程中，会有提示需要让你输入hostname，
如果你的机器是k8s-master，则填写k8s-master，如果是k8s-node01则填写k8s-node01等等

# 安装完成后，控制台会打印如下信息,请妥善保存，后面步骤会用到：
kubeadm join 172.19.140.157:6443 --token wqntln.e6pmp2owx06t0bwm \
    --discovery-token-ca-cert-hash sha256:02e503684f853c56315d653b9a1627329b20cefec8619125c8d01fb313a5ae65 
```

###安装k8s-node01环境，进入k8s-node01服务器的/home目录，执行如下命令步骤：
```
# 安装docker，执行如下命令
./install-docker.sh

# 执行脚本，安装k8s
./install-k8s-nodes.sh

# 注意事项
安装过程中，会有提示需要让你输入hostname, 方法同上

# 安装成功后，将node加入到集群，执行在安装k8s-master完成后保存的命令：
kubeadm join 172.19.140.157:6443 --token wqntln.e6pmp2owx06t0bwm \
    --discovery-token-ca-cert-hash sha256:02e503684f853c56315d653b9a1627329b20cefec8619125c8d01fb313a5ae65 

# 执行成功后，在k8s-master服务器上，执行kubectl get nodes, 得到如下结果：
NAME         STATUS   ROLES    AGE   VERSION
k8s-master   Ready    master   67m   v1.18.2
k8s-node01   Ready    <none>   62m   v1.18.2

# 如果你的某个节点STATUS是NotReady，可以重启一下该节点的docker，执行如下命令重启：
systemctl restart docker

# 然后再执行kubectl get nodes查看状态，网络可能有延迟，可以等待一会再执行
```

### k8s-node02的安装和k8s-node01是一样的

    






