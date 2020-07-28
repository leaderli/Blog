---
title: freeswitch
date: 2020-07-04 21:48:37
categories: ivr
tags:
---

## 安装 freeswtich

在 centos7 上安装，参考[官方安装文档](https://freeswitch.org/confluence/display/FREESWITCH/CentOS+7+and+RHEL+7#CentOS7andRHEL7-CentOS7andRHEL7-Stable)

```shell

# 可能需要安装的前置依赖
yum install -y subversion autoconf automake libtool gcc-c++
yum install -y ncurses-devel make libtiff-devel libjpeg-devel

yum install -y https://files.freeswitch.org/repo/yum/centos-release/freeswitch-release-repo-0-1.noarch.rpm epel-release
yum install -y freeswitch-config-vanilla
# 语言和语音可按需安装
yum search freeswitch-lang-
yum search freeswitch-sounds-
# 根据需要安装
# yum  install - y freeswitch-lang-*
# yum  install - y freeswitch-sounds-*
systemctl enable freeswitch
systemctl start freeswitch
# 进入freeswtich
fs_cli -rRS
```

如果报错，说明没有启动成功，尝试使用 root 启动

```shell
[ERROR] fs_cli.c:1691 main() Error Connecting []
[info] fs_cli.c:1697 main() Retrying
```

## 安装一个 sip 软电话

[telephone mac](https://apps.apple.com/us/app/telephone/id406825478?mt=12)

安装完成后配置账号，FreeSWITCH 默认配置了 1000 ~ 1019 共 20 个用户，你可以随便选择一个用户进行配置：

```txt
Display Name: 1000
User name: 1000
Password: 1234
Authorization user name: 1000
Domain: freeswitch的IP地址（默认使用5060端口）
```

## 开始测试

freeswitch 默认测试号码

```shell
------------------
号码        |   说明
----------------------
9664      |   保持音乐
9196      |   echo，回音测试
9195      |   echo，回音测试，延迟5秒
9197      |   milliwatte extension，铃音生成
9198      |   TGML 铃音生成示例
5000      |   示例IVR
4000      |   听取语音信箱
33xx      |   电话会议，48K(其中xx可为00-99，下同)
32xx      |   电话会议，32K
31xx      |   电话会议，16K
30xx      |   电话会议，8K
2000-2002 |   呼叫组
1000-1019 |   默认分机号

表一： 默认号码及说明
```

## freeswitch cli

在 freeswitch 客户端，我们将日志级别设置到合适的级别

```shell
freeswitch@CentOS7> /help
Command                     Description
-----------------------------------------------
/help                       Help
/exit, /quit, /bye, ...     Exit the program.
/event, /noevents, /nixevent  Event commands.
/log, /nolog                Log commands.
/uuid                       Filter logs for a single call uuid
/filter                     Filter commands.
/logfilter                  Filter Log for a single string.
/debug [0-7]                Set debug level.

```

### 重新加载配置文件

reloadxml

## 配置简介

```shell
文件                               |    说明
---------------------------------------------------
vars.xml                          | 一些常用变量
dialplan/default.xml              | 缺省的拨号计划
directory/default/*.xml           | SIP用户，每用户一个文件
sip_profiles/internal.xml         | 一个SIP profile，或称作一个SIP-UA，监听在本地IP及端口5060，一般供内网用户使用
sip_profiles/externa.xml          | 另一个SIP-UA，用作外部连接，端口5080
autoload_configs/modules.conf.xml | 配置当FreeSWITCH启动时自动装载哪些模块
```

## 问题

### 拨打电话无声音

观察日志输出发现，可在 freeswitch 控制台或`/var/log/freeswitch/freeswitch.log`中查看

```shell
Error Opening File [/usr/share/freeswitch/sounds/en/us/callie/ivr/ivr-to_call_the_freeswitch_conference.wav] [System error : No such file or directory.]
```

缺少相关语音包，我们可以安装对应的语音即可。

```shell
yum install -y freeswitch-sounds-en-us-callie-8000.noarch
```

### freeswitch 反应迟钝

测试中发现呼叫请求服务器处理的特别慢，后来跟踪发现在`/etc/freeswitch/conf/dialplan/default.xml` 中有个 sleep 10s 的处理，

```xml
<condition field="${default_password}" expression="^1234$" break="never">
        <action application="log" data="CRIT WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING "/>
        <action application="log" data="CRIT Open $${conf_dir}/vars.xml and change the default_password."/>
        <action application="log" data="CRIT Once changed type 'reloadxml' at the console."/>
        <action application="log" data="CRIT WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING "/>
        <action application="sleep" data="10000"/>
</condition>
```

我们可以注释掉这个`sleep`，或者修改默认密码，`/etc/freeswitch/conf`，编译 vars.xml，把默认的密码 1234 改成其他。
