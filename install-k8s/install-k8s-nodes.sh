#!/bin/bash

K8S_VERSION=1.18.2

echo "###卸载K8S###"
kubeadm reset -f
modprobe -r ipip
lsmod
rm -rf ~/.kube/
rm -rf /etc/kubernetes/
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /etc/systemd/system/kubelet.service
rm -rf /usr/bin/kube*
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /var/lib/etcd
rm -rf /var/etcd
yum remove -y kubelet-$K8S_VERSION kubeadm-$K8S_VERSION kubectl-$K8S_VERSION

echo "###关闭防火墙###"
systemctl stop firewalld && systemctl disable firewalld

echo "###关闭selinux###"
setenforce 0  # 临时关闭
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo "###关闭swap###"
apoff -a
sed -ri 's/.*swap.*/#&/' /etc/fstab

echo "###设置主机名###"
echo "参考hostname命名: k8s-master,k8s-node01,k8s-node02,k8s-xxxxxx"
read -p "请输入本机设置的hostname: " hostname
hostnamectl set-hostname $hostname

echo "hostname: $hostname 设置成功！"

#配置节点hosts
echo "###请配置节点IP和hostname到hosts文件###"
cat >> /etc/hosts << EOF
  172.19.140.157 k8s-master
  172.19.140.152 k8s-node01
  172.19.140.160 k8s-node02
EOF

echo "###内核调整,将桥接的IPv4流量传递到iptables的链###"
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "###设置系统时区并同步时间服务器###"
yum install -y ntpdate
ntpdate time.windows.com

echo "###查看linux内核###"
uname -r

echo "###添加kubernetes YUM软件源###"
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[k8s]
name=k8s
enabled=1
gpgcheck=0
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
EOF

echo "###安装kubeadm,kubelet和kubectl###"
yum install -y kubelet-$K8S_VERSION kubeadm-$K8S_VERSION kubectl-$K8S_VERSION
systemctl enable kubelet

