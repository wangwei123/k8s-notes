### k8s部署一个nginx应用

首先创建文件 nginx-deployment.yaml，内容如下：
```yaml
apiVersion: apps/v1	#与k8s集群版本有关，使用 kubectl api-versions 即可查看当前集群支持的版本
kind: Deployment	#该配置的类型，我们使用的是 Deployment
metadata:	        #译名为元数据，即 Deployment 的一些基本属性和信息
  name: nginx-deployment	#Deployment 的名称
  labels:	    #标签，可以灵活定位一个或多个资源，其中key和value均可自定义，可以定义多组，目前不需要理解
    app: nginx	#为该Deployment设置key为app，value为nginx的标签
spec:	        #这是关于该Deployment的描述，可以理解为你期待该Deployment在k8s中如何使用
  replicas: 1	#使用该Deployment创建一个应用程序实例
  selector:	    #标签选择器，与上面的标签共同作用，目前不需要理解
    matchLabels: #选择包含标签app:nginx的资源
      app: nginx
  template:	    #这是选择或创建的Pod的模板
    metadata:	#Pod的元数据
      labels:	#Pod的标签，上面的selector即选择包含标签app:nginx的Pod
        app: nginx
    spec:	    #期望Pod实现的功能（即在pod中部署）
      containers:	#生成container，与docker中的container是同一种
      - name: nginx	#container的名称
        image: nginx:1.7.9	#使用镜像nginx:1.7.9创建container，该container默认80端口可访问

```

执行apply部署nginx应用:
```shell
kubectl apply -f nginx-deployment.yaml
```
查看部署结果:
```shell
# 查看 Deployment
kubectl get deployments

#输出结果如下,因为replicas(副本数)为1,只有一个deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   1/1     1            1           7d18h

# 查看 Pod
kubectl get pods

#输出结果如下,因为replicas(副本数)为1,只有一个pod
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-7c96855774-892nr   1/1     Running   0          17h
```
对外提供访问服务，创建文件 nginx-service.yaml，内容如如下:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service	#Service 的名称
  labels:     	#Service 自己的标签
    app: nginx	#为该 Service 设置 key 为 app，value 为 nginx 的标签
spec:	    #这是关于该 Service 的定义，描述了 Service 如何选择 Pod，如何被访问
  selector:	    #标签选择器
    app: nginx	#选择包含标签 app:nginx 的 Pod
  ports:
  - name: nginx-port	#端口的名字
    protocol: TCP	    #协议类型 TCP/UDP
    port: 80	        #集群内的其他容器组可通过 80 端口访问 Service
    nodePort: 32600   #通过任意节点的 32600 端口访问 Service
    targetPort: 80	#将请求转发到匹配 Pod 的 80 端口
  type: NodePort	#Serive的类型，ClusterIP/NodePort/LoaderBalancer
```

创建服务和访问服务
```shell
#创建服务
kubectl apply -f nginx-service.yaml

#查看执行结果，可查看到名称为 nginx-service 的服务
kubectl get services -o wide

#访问服务，节点IP可以执行cat /etc/hosts查看
curl <任意节点的 IP>:32600
```
伸缩应用程序 
修改nginx-deployment.yaml的replicas(副本数)实现伸缩
```yaml
spec:
  replicas: 3    #使用该Deployment创建3个应用程序实例
```

执行命令
```shell
#创建deployment
kubectl apply -f nginx-deployment.yaml

#查看执行结果
watch kubectl get pods -o wide

# 查看 Deployment
kubectl get deployments

#输出结果如下,因为replicas(副本数)为3,现在有3个deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           7d18h

# 查看 Pod
kubectl get pods

#输出结果如下,因为replicas(副本数)为3,现在有3个pod
nginx-deployment-7c96855774-892nr   1/1     Running   0          17h
nginx-deployment-7c96855774-nptkv   1/1     Running   0          2m4s
nginx-deployment-7c96855774-xq54b   1/1     Running   0          2m4s

```

滚动发布，在不停止现有服务的情况下，通过逐个创建新的Pod替换旧的Pod，实现滚动发布 
修改 nginx-deployment.yaml中的image: nginx:1.7.9为nginx:1.8,内容如下：
```yaml
    spec:
      containers:
      - name: nginx
        image: nginx:1.8   #使用镜像nginx:1.8替换原来的nginx:1.7.9
```

执行命令
```shell
#创建deployment
kubectl apply -f nginx-deployment.yaml

#执行命令，可观察到 pod 逐个被替换的过程
watch kubectl get pods -l app=nginx
```








