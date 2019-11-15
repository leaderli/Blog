---
title: docker基础
date: 2019-07-22 21:22:57
categories: docker
tags:
- docker
- 基础教程
---
## 指南

### 安装

[官方安装文档](https://docs.docker.com/install/)

`docker --version` 查看版本号
`docker info` 查看docker详细信息

### 概述

#### image

容器是由镜像文件加载启动的。镜像是一个可执行文件，包含运行应用程序所需要的所有资源，包括
代码，运行环境，环境变量，配置文件等。
可通过`docker images`查看所有镜像

```shell
REPOSITORY                                             TAG                 IMAGE ID            CREATED             SIZE
jenkins/jenkins                                        2.138.4             b8efbb99cea6        7 months ago        701MB
registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g   latest              3fa112fd3642        3 years ago         6.85GB
```

#### container

容器是镜像的运行实例，容器共享宿主机的`kernel`内核，独立进程运行，不占用其他任何可执行文件的内存。

部分命令

```shell
## List Docker CLI commands
docker
docker container --help

## Display Docker version and info
docker --version
docker version
docker info

## Execute Docker image
docker run hello-world

## List Docker images
docker image ls

## List Docker containers (running, all, all in quiet mode)
docker container ls
docker container ls --all
docker container ls -aq
```

## 容器

### 创建自己的容器

通过`Dockerfile`定义镜像
新建一个空目录，`cd`进入目录，编辑`Dockerfile`文件

```bash
# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
```

根据上述`Dockerfile`新建`requirements.txt`和`app.py`

```txt
Flask
Redis
```

```python
from flask import Flask
from redis import Redis, RedisError
import os
import socket

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```

执行`docker build -t=friendlyhello .`
等待编译完成后通过`docker image ls`可查看到已经编译好的镜像

```bash
REPOSITORY                                             TAG                 IMAGE ID            CREATED             SIZE
friendlyhello                                          latest              9f7c2034a1f3        27 seconds ago      148MB
python                                                 2.7-slim            5caa018c2dc0        9 days ago          137MB
```

 执行`docker run -d -p 4000:80 friendlyhello`，以后台进程的方式运行容器

 可通过[http://localhost:4000](http://localhost:4000)访问首页

版本控制
`docker tag image username/repository:tag`

部分命令

```bash
docker build -t friendlyhello .  # Create image using this directory's Dockerfile
docker run -p 4000:80 friendlyhello  # Run "friendlyhello" mapping port 4000 to 80
docker run -d -p 4000:80 friendlyhello         # Same thing, but in detached mode
docker container ls                                # List all running containers
docker container ls -a             # List all containers, even those not running
docker container stop <hash>           # Gracefully stop the specified container
docker container kill <hash>         # Force shutdown of the specified container
docker container rm <hash>        # Remove specified container from this machine
docker container rm $(docker container ls -a -q)         # Remove all containers
docker image ls -a                             # List all images on this machine
docker image rm <image id>            # Remove specified image from this machine
docker image rm $(docker image ls -a -q)   # Remove all images from this machine
docker login             # Log in this CLI session using your Docker credentials
docker tag <image> username/repository:tag  # Tag <image> for upload to registry
docker push username/repository:tag            # Upload tagged image to registry
docker run username/repository:tag                   # Run image from a registry
```

## 服务化

## 下载镜像

`docker pull name:tag`
`name`镜像名
`tag`镜像版本

>若速度较慢，可以配置阿里云镜像加速 [镜像加速参考文档](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)

## 删除镜像

`docker images`查看所有镜像
`dockder rmi 'image_id'`删除镜像

## 查看日志

```shell
docker logs [OPTIONS] CONTAINER
  Options:
        --details        显示更多的信息
    -f, --follow         跟踪实时日志
        --since string   显示自某个timestamp之后的日志，或相对时间，如42m（即42分钟）
        --tail string    从日志末尾显示多少行日志， 默认是all
    -t, --timestamps     显示时间戳
        --until string   显示自某个timestamp之前的日志，或相对时间，如42m（即42分钟）
```

查看指定时间后的日志，只显示最后100行：

```shell
docker logs -f -t --since="2018-02-08" --tail=100 CONTAINER_ID`
```

查看最近30分钟的日志:

```shell
docker logs --since 30m CONTAINER_ID
```

查看某时间之后的日志：

```shell
docker logs -t --since="2018-02-08T13:23:37" CONTAINER_ID
```

查看某时间段日志：

```shell
docker logs -t --since="2018-02-08T13:23:37" --until "2018-02-09T12:23:37" CONTAINER_ID
```

## 挂载宿主目录

`-v`可重复使用，指定多个目录

```shell
docker run -d -p 8002:8080 -v ~/jenkins:/var/jenkins_home -v /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home:/mnt/java -v /usr/local/Cellar/maven/3.6.1:/mnt/maven -v /Users/li/.m2:/mnt/.m2 --name jenkins --restart=always jenkins/jenkins:2.138.4

```

`/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home:/mnt/java`挂载jdk

## 进入容器

`docker exec -it 6bcaf729d3d4 bash`

`6bcaf729d3d4`容器id，可通过`docker ps`查看

```shell
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
6bcaf729d3d4        jenkins             "/bin/tini -- /usr/l…"   31 seconds ago      Up 29 seconds       50000/tcp, 0.0.0.0:8002->8080/tcp   jenkins
```

以root权限登录
`sudo docker exec -ti -u root 6bcaf729d3d4 bash`

## 容器内vi安装

进入容器中使用vi提示不存在

`apt-get update`更新软件包管理工具
`apt-get install vi`安装vi
