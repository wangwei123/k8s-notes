#!/bin/bash

echo "###yum 包更新###"
sudo yum update

echo "###开始安装docker###"
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

echo "###查询docker稳定版本清单###"
yum list docker-ce --showduplicates | sort -r

read -p "请输入您想安装的docker版本号(例如: 19.03.8): " docker_version
yum install docker-ce-$docker_version docker-ce-cli-$docker_version containerd.io

systemctl enable docker.service
systemctl start docker

echo "###docker安装完成！###"
yum install docker-ce docker-ce-cli containerd.io

#echo "###docker运行一个hello-world容器###"
#docker run hello-world

echo ""
echo "###查看docker版本信息###"
docker --version




