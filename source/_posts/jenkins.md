---
title: jenkins
date: 2019-12-16 23:55:19
categories: java
tags:
  - centos
  - jenkins
---

## 安装

使用`centos 7`系统安装的`jenkins`服务，

使用安装包进行安装。

```bash
wget https://pkg.jenkins.io/redhat/jenkins-2.213-1.1.noarch.rpm
rpm -ivh jenkins-2.213-1.1.noarch.rpm
```

使用`yum`安装

添加 Jenkins 库到 yum 库，Jenkins 将从这里下载安装。

```bash
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum install -y jenkins
```

### 安装过程可能出现的问题

当未卸载干净`jenkins`再进行重装时可能会出现的问题

```txt
stat: cannot stat ‘/var/cache/jenkins’: No such file or directory
stat: cannot stat ‘/var/log/jenkins’: No such file or directory
stat: cannot stat ‘/var/lib/jenkins’: No such file or directory
error: %pre(jenkins-2.150.1-1.1.noarch) scriptlet failed, exit status 1
Error in PREIN scriptlet in rpm package jenkins-2.150.1-1.1.noarch
  Verifying  : jenkins-2.150.1-1.1.noarch                                                                                                                                                                      1/1

Failed:
  jenkins.noarch 0:2.150.1-1.1
```

问题的关键是`PREIN scriptlet`，就是`preinstall scriptlet`，这是`rpm`在安装前执行的一段`sh`脚本，为安装创建相应的文件夹什么的。

上面的三个`No such file or directory`显然就是，这三个文件夹没有被创建好。

```bash
yum install jenkins  --downloadonly --downloaddir=/root
rpm --scripts -qp jenkins-2.150.1-1.1.noarch.rpm > jenkins.log
```

查看输出的日志

```txt
if [ -f "/etc/sysconfig/jenkins" ]; then
      logger -t jenkins.installer "Found previous config file /etc/sysconfig/jenkins"
      . "/etc/sysconfig/jenkins"
      stat --format=%U "/var/cache/jenkins" > "/tmp/jenkins.installer.cacheowner"
      stat --format=%U "/var/log/jenkins"  >  "/tmp/jenkins.installer.logowner"
      stat --format=%U ${JENKINS_HOME:-/var/lib/jenkins}  > "/tmp/jenkins.installer.workdirowner"
  else
      logger -t jenkins.installer "No previous config file /etc/sysconfig/jenkins found"
  fi
```

这问题就很明白了，结合前面的`stat`报错，明确了就是这段报错误。这段的意思是，如果`/etc/sysconfig/jenkins`存在，执行下面一系列操作，应该是为了重复安装写的。

删除文件夹`/var/lib/jenkins,/var/log/jenkins/,/var/cache/jenkins`即可

## 启动

`jenkins`启动时会输出日志，可通过查看日志定位具体错误信息。

```bash
tail -f /var/log/jenkins/jenkins.log
```

使用`rpm`安装`jenkins`时，默认会创建`jenkins:jenkins`的用户以及用户组，如果用其他用户启动，需要将以下文件夹用户以及用户组变更

1. /usr/lib/jenkins/jenkins.war WAR 包
2. /etc/sysconfig/jenkins 配置文件
3. /var/lib/jenkins/ 默认的 JENKINS_HOME 目录
4. /var/log/jenkins/jenkins.log Jenkins 日志文件

启停服务,使用`systemctl`工具操作`jenkins`

```shell
systemctl start jenkins
systemctl stop jenkins
systemctl status jenkins
```

### 修改端口

`vi /etc/sysconfig/jenkins`修改`JENKINS_PORT="8081"`

### 防火墙

当虚拟机外部需要访问`jenkins`时，需要将`centos`的防火墙关闭

1. 使用命令`systemctl status firewalld.service`查看防火墙状态
2. 使用命令`systemctl disable firewalld.service`，即可永久禁止防火墙服务
