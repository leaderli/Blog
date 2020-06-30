---
title: jenkins远程发布
date: 2019-07-22 20:45:38
categories: 工具
tags:
  - jenkins
  - docker
  - tomact
---

## 版本说明

省略 docker 安装过程

`docker version`

```log
Client:
 Version:           18.06.1-ce
 API version:       1.38
 Go version:        go1.10.3
 Git commit:        e68fc7a
 Built:             Tue Aug 21 17:21:31 2018
 OS/Arch:           darwin/amd64
 Experimental:      false

Server:
 Engine:
  Version:          18.06.1-ce
  API version:      1.38 (minimum version 1.12)
  Go version:       go1.10.3
  Git commit:       e68fc7a
  Built:            Tue Aug 21 17:29:02 2018
  OS/Arch:          linux/amd64
  Experimental:     true
```

`java -version`

```log
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

## 安装 Jenkins 镜像

```shell
docker pull jenkins/jenkins:2.138.1-slim
```

拉取的是 2.138.1-slim 版本的 jenkins，可通过命令查看下载的版本

`docker images`

```log
REPOSITORY                                             TAG                 IMAGE ID            CREATED             SIZE
jenkins                                                latest              cd14cecfdb3a        12 months ago       696MB
```

## 启动 Jenkins

```shell
docker run -d -p 8002:8080 -v ~/jenkins:/var/jenkins_home -v /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home:/mnt/java -v /usr/local/Cellar/maven/3.6.1:/mnt/maven --name jenkins --restart=always jenkins/jenkins:2.138
```

`8002:8080` 本地 8002 端口映射容器 8080 端口

查看启动日志
`docker logs -f jenkins`
可以看到`jenkins`的默认`admin`密码

```log
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

8b34af422fa24794bdb86d3e299162bd

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```

界面访问[`127.0.0.1:8002`](http://127.0.0.1:8002),自动跳转至登录界面,首次进线输入默认密码，登录后安装推荐插件。

jenkins 插件镜像

页面依次点击/Manage Jenkins/Manage Plugins/Advanced
镜像地址：

```shell
https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json
```

![jenkins插件镜像](jenkins远程发布/jenkins插件镜像.jpg)
