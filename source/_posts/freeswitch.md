---
title: freeswitch
date: 2020-07-04 21:48:37
categories: ivr
tags:
---

[官方文档](https://freeswitch.org/confluence/display/FREESWITCH/FreeSWITCH+First+Steps)

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
```

## 启动

```shell

# 以系统服务启动freeswitch
systemctl enable freeswitch
systemctl start freeswitch

# 直接启动
# -nc 后台启动
# -nonat 关闭uPnP
freeswitch -nc -nonat

# 查看freeswitch进程
ps -ef|grep freeswitch
# 查看相关端口是否被占用，默认使用的是5060端口
# -p 能直接得到freeswitch的进程号（需root权限)
netstat -anp|grep 5060


# 进入freeswtich
# 如果报错，说明没有启动成功，尝试使用 root 启动
fs_cli -rRS
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

<em class="grey">密码默认为 1234，可在 var.xml 中更改</em>

## 入门测试

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

## freeswitch cli 简介

### 参数

1. `-x` 执行一条命令后退出
   `fs_cli -x "version"`
   > FreeSWITCH Version 1.10.3-release.5~64bit (-release.5 64bit)

### 连接其他服务器

在用户根目录下编辑配置文件`.fs_cli_conf`

```conf
[server1]
host      => 192.168.0.1
port      => 8081
password  => password
debug     => 7
```

配置好后即可使用`fs_cli sever1`连接

### 客户端特殊命令

fs_cli 中，有几个特殊命令，以`/`开头,这些命令并不直接发送到服务端，而由`fs_cli`直接处理

例如 fs_cli 中，我们将日志级别设置到合适的级别

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

### 快捷键

在`fs_cli`中，我们可以使用`F1-F12`的快捷键，快捷键的功能定义在配置文件`autoload_configs/switch.conf.xml`中

```xml
<cli-keybindings>
    <key name="1" value="help"/>
    <key name="2" value="status"/>
    <key name="3" value="show channels"/>
    <key name="4" value="show calls"/>
    <key name="5" value="sofia status"/>
    <key name="6" value="reloadxml"/>
    <key name="7" value="console loglevel 0"/>
    <key name="8" value="console loglevel 7"/>
    <key name="9" value="sofia status profile internal"/>
    <key name="10" value="sofia profile internal siptrace on"/>
    <key name="11" value="sofia profile internal siptrace off"/>
    <key name="12" value="version"/>
  </cli-keybindings>
```

## 配置简介

我安装的 freeswitch 的配置文件在`/etc/freeswitch`目录下

### 配置文件概述

```shell
文件                               |    说明
---------------------------------------------------
freeswitch.xml                    | 核心配置文件，整合所有配置文件
vars.xml                          | 全局变量
dialplan/default.xml              | 缺省的拨号计划
directory/default/*.xml           | SIP用户，每用户一个文件
sip_profiles/internal.xml         | 一个SIP profile，或称作一个SIP-UA，监听在本地IP及端口5060，一般供内网用户使用
sip_profiles/externa.xml          | 另一个SIP-UA，用作外部连接，端口5080
autoload_configs/modules.conf.xml | 配置当FreeSWITCH启动时自动装载哪些模块
```

- 配置文件中`X-PRE_PROCESS`标签，是 FreeSwitch 特有的，它称为预处理指令，用于设置一些变量和引入其他配置文件，在 XML 加载阶段，FreeSwitch 的 XML 解析器会将所有预处理命令展开.
- 在 FreeSwitch 内部生成一个大的 XML 文档。`log/freeswitch.xml.fsxml`是 FreeSwitch 内部 XML 的一个内存镜像，它对调试非常有用，可以了解运行中的 FreeSwitch 的配置。
- `X-PRE_PROCESS`是一个预处理指令，是 FreeSwitch 在加载阶段只针对其文本内容进行简单替换，而不是在解析 xml 阶段进行替换，因此注释`X-PRE_PROCESS`指令时，遇到嵌套的注释时会产生错误的 XML
- 通过`X-PRE_PROCESS`设置的变量都称为全局变量，在加载 vars.xml 之前，FreeSwitch 已经设置了一些全局变量。在 xml 中使用`$${var}`引用全局变量，`${var}`引用局部变量。可使用`global_getvar`查看全局变量。

  ```shell
  fs_cli> global_getvar
  hostname=CentOS7
  local_ip_v4=10.211.55.6
  local_mask_v4=255.255.255.0
  local_ip_v6=fdb2:2c26:f4e4:0:4436:96d:47c1:1aa9
  base_dir=/usr
  recordings_dir=/var/lib/freeswitch/recordings
  sounds_dir=/usr/share/freeswitch/sounds
  conf_dir=/etc/freeswitch
  log_dir=/var/log/freeswitch
  run_dir=/var/run/freeswitch
  db_dir=/var/lib/freeswitch/db
  mod_dir=/usr/lib64/freeswitch/mod
  htdocs_dir=/usr/share/freeswitch/htdocs
  ...
  ```

全局变量在预处理阶段（系统启动时或 reloadxml 时）被求值。局部变量在每次执行时都求值。

### 用户目录

用户目录默认配置文件在`conf/directory`下

### 重新加载配置文件

fs_cli> `reloadxml`

## 基础知识

### SIP

SIP 协议采用 Client/Server 模型，每一个请求（request），Server 从接受到请求到处理完毕，要回复多个临时响应，和有且仅有一个终结响应（response）。

Transaction 请求和所有的响应构成一个事务，一个完整的呼叫过程包括多个事件。

UA 用户代理，是发起或接受呼叫的逻辑实体

UAC 用户代理客户端，用于发起请求

UAS 用户代理服务器，用于接受请求

UAC 和 UAS 的划分是针对一个事务的，在一个呼叫的多个事务中，UAC 和 UAS 的角色是可以互相转换的

B2BUA 是一个 SIP 中逻辑上的网络组件，用于操作不同会话的端点，它将 channel 划分为两路通话，在不同会话的端点直接通信。例如，当建立一通呼叫时，B2BUA 作为一个 UAS 接受所有用户请求，处理后以 UAC 角色转发至目标端。
![freeswitch_B2BUA.png](./images/freeswitch_B2BUA.png)

### Channel

对于每一次呼叫，FreeSwitch 都会启动一个 Session，用于控制整个呼叫，他会一直持续到通话结束。其中，每个 Session 都控制这一个 Channel（通道，又称信道），是一对 UA 间通信的实体，相当于 FreeSwitch 的一条腿。每个 channel 都用一个唯一的 UUID 来标示，称为 channel UUID。。Channel 上可以绑定一些呼叫参数，称为 Channel Variable（通道变量）。Channel 也可用来传输媒体流。通话时 FreeSwitch 的作用是将两个 Channel 桥接（bridge）到一起，使双方可以通话。这两路桥接的通话（两条腿）在逻辑上组成一个通话，称为一个 Call
一个通道有两端，常用的端

- park 挂起
- hold 挂起并播放提示音
- record 录音
- playback 播放提示音
- bridge 桥接其他用户

### 其他

RTP [实时传输协议](https://en.wikipedia.org/wiki/Real-time_Transport_Protocol)

## 常用命令

1. `sofia status profile internal reg`查看注册用户

```properties
Call-ID:    03frJ9rXlraWYhLWGiu-PzxSW.9VWb6S
User:       1000@10.211.55.6
Contact:    "1000" <sip:1000@10.211.55.2:57146;ob>
Agent:      Telephone 1.4.6
Status:     Registered(UDP)(unknown) EXP(2020-07-17 08:04:09) EXPSECS(337)
Ping-Status:Reachable
Ping-Time:  0.00
Host:       CentOS7
IP:         10.211.55.2
Port:       57146
Auth-User:  1000
Auth-Realm: 10.211.55.6
MWI-Account:1000@10.211.55.6
```

`Contact`地址可得知用户 1000 的 sip 地址：`sip:1000@10.211.55.2`,当我们使用 originate 命令呼叫`user/1000`这个呼叫字符串时，FreeSWITCH 便会在用户目录中查找 1000 这个用户，找到他的 dial-string 参数，dial-string 通常包含 alice 实际 Contact 地址的查找方法

2. originate 发起呼叫
   `originate user/1000 &park`
3. show channels 显示通道信息

4. bridge 桥接(先桥接，后呼叫)
   `originate user/1000 &bridge(user/10001)`。
   我们也可以使用另一种方式来建立他们之间的连接（先呼叫，后桥接）

   ```shell
   originate user/1000 &park
   originate user/1001 &park
   show channels
   uuid_bridge <1000_uuid> <1001_uuid>
   ```

## 架构

freeSWTICH 由一个稳定的核心（Core）及一些外围模块组成。FreeSwitch 内部使用线程模型来处理并发请求，每个连接都在单独的线程中进行处理，不同的线程间通过 Mutex 互斥访问共享资源，并通过消息和异步事件等方式进行通信。FreeSwitch 的核心非常短小精悍，绝大部分应用层的功能都在外围的模块中实现。外围模块可以动态加载（以及卸载）。外围模块与核心模块通过核心提供的 Public API 与核心进行通信，而核心通过回调（或称钩子）机制执行外围模块中的代码。

![freeswitch_架构.png](./images/freeswitch_架构.png)

### 数据库

FreeSwitch 使用一个核心的数据库（默认的存放位置是/usr/local/freeswitch/db/core.db）来记录系统的接口（interfaces），任务（tasks）以及当前的通道（channels），通话（calls）等实时数据。某些模块，如 mod_sofia，有自己的数据库（表），一般情况下，这些模块提供相关的 API 用于从这些表里查询数据。

### 公共应用程序接口

FreeSwitch 在核心层实现了一些 Public API，这些 Public API 可以被外围的模块调用。包含一些通用的工具函数，如生成 JSON 格式的函数，RTP 等与呼叫相关。

### 接口

FreeSwitch 提供了很多抽象接口，这些接口对同类型的逻辑或功能实体进行了抽象，但没有具体实现。核心层通过回调（钩子）方式调用具体的实现代码或函数。

例如 FreeSwitch 核心层定义了以下接口

```c
typedef enum {
   SWITCH_ENDPOINT_INTERFACE,
   SWITCH_TIMER_INTERFACE,
   SWITCH_DIALPLAN_INTERFACE,
   SWITCH_CODEC_INTERFACE,
   SWITCH_APPLICATION_INTERFACE,
   SWITCH_API_INTERFACE,
   SWITCH_FILE_INTERFACE,
   SWITCH_SPEECH_INTERFACE,
   SWITCH_DIRECTORY_INTERFACE,
   SWITCH_CHAT_INTERFACE,
   SWITCH_SAY_INTERFACE,
   SWITCH_ASR_INTERFACE,
   SWITCH_MANAGEMENT_INTERFACE,
   SWITCH_LIMIT_INTERFACE,
   SWITCH_CHAT_APPLICATION_INTERFACE,
   SWITCH_JSON_API_INTERFACE,
   SWITCH_DATABASE_INTERFACE,
} switch_module_interface_name_t;
```

外围模块可以选择并实现其中一个或多个接口，并向核心层`注册`这些接口，核心层在需要这些接口时，会回调这些接口中约定的回调函数。

### 事件

FreeSwitch 内部使用消息和事件机制进行进程间和模块间的通信。事件进制既可以在内部使用，也可在外部使用。事件机制是一种`生产者－消费者`模型，事件的产生和处理是异步的。这些事件可以在 FreeSwitch 内部通过绑定（Bind）一定的回调函数进行捕获，即 FreeSwitch 的核心事件系统会依次回调这些回调函数，完成相应的功能。另外，在嵌入式脚本中也可以订阅相关的事件进行处理。
在 FreeSwitch 外部，也可以通过 Event Socket 等接口订阅相关的事件，通过这种方式了解 FreeSwitch 内部发生了什么，如当前呼叫的状态等。fs_cli 就是一个典型的外呼程序，通过 Event Socket 与 FreeSwitch 通信，可以对 FreeSwitch 进行控制和管理，也可以订阅相关的事件对 FreeSwitch 的运行情况进行监控。订阅事件最简单的方法是：

```shell
# 订阅所有事件
fs_cli> /event plain ALL

# 单独订阅某类事件
fs_cli> /event plain  CHANNERL_ANSWER
fs_cli> /event plain  CUSTOM sofia:register
```

当我们使用登录软电话时，我们可以看到`sofia:register`信息

```shell
fs_cli> /event plain CUSTOM sofia::register
+OK event listener enabled plain

#登录后
fs_cli@CentOS7>
RECV EVENT
Event-Subclass: sofia::register
Event-Name: CUSTOM
Core-UUID: 11995eb7-bd00-492b-96c2-73a3256a383c
FreeSWITCH-Hostname: CentOS7
FreeSWITCH-Switchname: CentOS7
FreeSWITCH-IPv4: 10.211.55.6
FreeSWITCH-IPv6: fdb2:2c26:f4e4:0:4436:96d:47c1:1aa9
Event-Date-Local: 2020-07-17 15:03:21
Event-Date-GMT: Fri, 17 Jul 2020 07:03:21 GMT
Event-Date-Timestamp: 1594969401524081
Event-Calling-File: sofia_reg.c
Event-Calling-Function: sofia_reg_handle_register_token
Event-Calling-Line-Number: 2007
Event-Sequence: 1161
profile-name: internal
from-user: 1000
from-host: 10.211.55.6
presence-hosts: 10.211.55.6,10.211.55.6
contact: "1000" <sip:26759801@10.211.55.2:63078>
call-id: nEgIVmMHRtKSzdh6yv04x2SB.YkEJB84
rpid: unknown
status: Registered(UDP)
expires: 600
to-user: 1000
to-host: 10.211.55.6
network-ip: 10.211.55.2
network-port: 63078
username: 1000
realm: 10.211.55.6
user-agent: sipsimple 3.0.0
sip_number_alias: 1000
sip_auth_username: 1000
sip_auth_realm: 10.211.55.6
number_alias: 1000
user_name: 1000
domain_name: 10.211.55.6
record_stereo: true
default_gateway: example.com
default_areacode: 918
transfer_fallback_extension: operator
toll_allow: domestic,international,local
accountcode: 1000
user_context: default
effective_caller_id_name: Extension 1000
effective_caller_id_number: 1000
outbound_caller_id_name: FreeSWITCH
outbound_caller_id_number: 0000000000
callgroup: techsupport
```

### 目录结构

| 目录       | 说明                                         |
| :--------- | :------------------------------------------- |
| bin        | 可执行程序                                   |
| db         | 系统数据库(sqlite)                           |
| htdocs     | HTTP Server 根目录                           |
| lib        | 库文件                                       |
| mod        | 可加载模块                                   |
| run        | 运行目录，存放 FreeSwitch 运行时的 PID       |
| sounds     | 声音文件，使用 playback()默认的寻找路径      |
| grammar    | 语法，用于 ASR                               |
| include    | 头文件                                       |
| log        | 日志，CDR 等                                 |
| recordings | 录音，使用 record()时默认的存放路径          |
| scripts    | 嵌入式语言写的脚本，如 lua()等默认寻找的路径 |
| storage    | 语音留言（Voicemail）的录音                  |
| conf       | 配置文件                                     |

## APP

1. set 将变量设置到当前的 Channel，即 a-leg
   `hello=1`
2. export 除了具备 set 的功能外，还会将变量设置到 b-leg
   `hello=1`
3. hash 一个内存中的哈希表数据结构
   其 api 如下

   > hash insert/realm/key/value
   > hash insert_ifempty/realm/key/value
   > hash delete/realm/key
   > hash delete_ifmatch/realm/key/value
   > hash select/realm/key

   在 xml 配置中示例

   ```xml
   <action application="hash" data="delete_ifmatch/realm/key/value"/>
   <action application="set" data="var=${hash(select/realm/key)}"/>
   ```

## 拨号计划

拨号计划（Dialplan）是 FreeSwitch 中至关重要的一部分，它的主要作用就是对电话进行路由（从这一点上来说，相当于一个路由表），决定和影响通话的流程。路由查找和执行分别属于一路通话的不同阶段，当 channel 状态进入执行阶段后，才开始依次执行所有的 Action。

拨号计划的配置文件在`conf/dailplan`目录下，拨号计划由多个 Context 组成，每个 Context 中有多个 Extension。一个 Context 中的 Extension 与其他 Context 中的 Extension 在逻辑上是隔离的。在 Extension 中可以对一些 condition 进行判断，如果满足条件所指定的表达式，则执行对应的 Action。Action 通常有两个属性，一个是 Application,代表要执行的 App，一个是 data，代表 App 的参数。

Dialplan 的按顺序执行，为了避免与提供的例子冲突，建议将自己写的 Extension 放在最前面。
默认情况下一旦有 Extension 满足匹配规则，就不会再去查找其他的 Extension。我们可以使用参数`continue="true"`来继续执行其他 Extension

```xml
<extension name="tod_example" continue="true">
   <condition wday="2-6" hour="9-18">
      <action application="set" data="open=true"/>
   </condition>
</extension>
```

系统默认提供的配置文件包括三个 Context，分别是 default，features，public。default 是默认的 Dialplan，一般来说注册用户都可以通过它来打电话，如拨打其他分机和外部电话等。而 public 一般用户接受外来呼叫。

### 根据日志查看拨号详情

将日志级别调整为 DEBUG，拨打 9196 测试号码，截取整理部分日志

```log
1 mod_dialplan_xml.c:637 Processing 1000 <1000>->9196 in context default
2 parsing [default->unloop] continue=false
3 Regex (PASS) [unloop] ${unroll_loops}(true) =~ /^true$/ break=on-false
4 Regex (FAIL) [unloop] ${sip_looped_call}() =~ /^true$/ break=on-false
5 parsing [default->tod_example] continue=true
...
44 Regex (FAIL) [global] ${default_password}(10086) =~ /^1234$/ break=never
45 Regex (PASS) [echo] destination_number(9196) =~ /^9196$/ break=on-false
46 Action answer()
47 Action echo()
48 State Change CS_ROUTING -> CS_EXECUTE
```

1. 第一行：Processing 说明是在处理 Dialplan，其中 1000，是 sip 客户端软件注册的用户名
2. 第二行，呼叫进入 parsing（解析 XML）阶段，它首先根据呼叫的来源找到 XML 中的一个 Context，此处是 default。它找到的第一个 Extension 的 name 是 unloop。
   其实际 xml 配置如下

   ```xml
   <extension name="unloop">
      <condition field="${unroll_loops}" expression="^true$"/>
      <condition field="${sip_looped_call}" expression="^true$">
         <action application="deflect" data="${destination_number}"/>
      </condition>
   </extension>
   <extension name="echo">
      <condition field="destination_number" expression="^9196$">
         <action application="answer"/>
         <action application="echo"/>
      </condition>
   </extension>
   ```

3. 第三行，由于此处 Extension 有一个 Condition，判断变量 unroll_loops 是否为 true，条件满足
4. 第四行，由于此处 Extension 有一个 Condition，判断变量 sip_looped_call 是否为 true，条件不满足，不执行 Action
5. 第五行，执行下一个 name 为 tod_example 的 Extension
6. 第 45 行，判断被叫号(destination_number)是否满足 9196,条件满足，执行 answer 和 echo。answer 是一个 FreeSwitch 的 App，用于回复 200 OK 的 sip 信令。
7. 第 48 行，说明 FreeSwitch 进入执行阶段。

### 打印通道变量

配置 Extension，我们拨打 9916 时，触发 info 这个 App，我们可以看到很多 log 打印

```xml
<extension name="show channel variable">
   <condition field="destination_number" expression="^9916$">
      <action application="info" data=""/>
   </condition>
</extension>
```

```log
57da11b8 EXECUTE [depth=0] sofia/internal/1000@10.211.55.6 info()
57da11b8 2020-07-18 07:23:43.214675 [INFO] mod_dptools.c:1885 CHANNEL_DATA:
Channel-State: [CS_EXECUTE]
Channel-Call-State: [RINGING]
Channel-State-Number: [4]
Channel-Name: [sofia/internal/1000@10.211.55.6]
Unique-ID: [57da11b8-3197-45c4-bc31-bbe90935819e]
Call-Direction: [inbound]
Presence-Call-Direction: [inbound]
Channel-HIT-Dialplan: [true]
Channel-Presence-ID: [1000@10.211.55.6]
Channel-Call-UUID: [57da11b8-3197-45c4-bc31-bbe90935819e]
Answer-State: [ringing]
Caller-Direction: [inbound]
Caller-Logical-Direction: [inbound]
Caller-Username: [1000]
Caller-Dialplan: [XML]
Caller-Caller-ID-Name: [1000]
Caller-Caller-ID-Number: [1000]
Caller-Orig-Caller-ID-Name: [1000]
Caller-Orig-Caller-ID-Number: [1000]
Caller-Network-Addr: [10.211.55.2]
Caller-ANI: [1000]
Caller-Destination-Number: [9916]
Caller-Unique-ID: [57da11b8-3197-45c4-bc31-bbe90935819e]
Caller-Source: [mod_sofia]
Caller-Context: [default]
...
```

info 也可以打印指定变量

```xml
<action application="info" data="INFO the destination is  ${destination_number}"/>
```

info 打印的所有通道变量在 xml 中引用时，使用的名称和 info 打印出来的是不一致的，详见[wiki 参照表](https://freeswitch.org/confluence/display/FREESWITCH/Channel+Variables)

### condition

condition 使用正则表达式匹配测试一个变量是否满足预设的正则表达式。可测试的变量如
| 变量| 说明|
| :---- | :---- |
|context|Dialplan 当前的 Context|
|rdnis|被转移的号码|
|destination_number|被叫号码|
|dialplan|Dialplan 模块的名称|
|caller_id_name|主叫名称|
|caller_id_number|主叫号码|
|ani|主叫的自动号码识别|
|aniii|主叫类型，如投币电话|
|uuid|本 Channel 的唯一标示|
|source|呼叫源，来自 FreeSwitch 的哪一个模块|
|chan_name|channel 的名称|
|network_addr|主叫的 IP 地址|
|year|当前的年|
|yday|一年中的第几天 1~366|
|mon|月 1 ～ 12|
|mday|日 1 ～ 31|
|week|一年中的第几周 1 ～ 53|
|mweek|本月的第几周 1 ～ 6|
|wday|一周的第一天 1 ～ 7 周日代表 1|
|hour|小时 0 ～ 23|
|minute|分钟 0 ～ 59|
|minute-of-day|一天中的第几分钟 1 ～ 1440|

除此之外，还可以使用用户目录设置的变量。但需要使用`${}`引用

condition 只要满足即执行其中的 action，否则执行其中的 anti-action。

condition 不可以嵌套，但可以迭加，通过属性 break 的值，我们可以确定是否继续执行接下来的 condition

break 的值的含义（假设我们有两个 condition，分别为 A 和 B）:

- `on-false`（默认值） 在第一次匹配失败时停止，即当 A 为 false 时，直接完成当前 Extension
- `on-true` 在第一次匹配成功时停止，即当 A 为 false 时，才会去测试 B
- `always` 不管是否匹配都停止
- `never` 不管是否匹配都继续

### Dialplan 工作机制

channel 的状态机

```mermaid
graph LR
    NEW       --> INIT
    INIT      --> ROUTING
    ROUTING  --> EXECUTE
    EXECUTE   --> HANGUP
    EXECUTE   -.->|transfer|ROUTING
    HANGUP    --> REPORTING
    REPORTING --> DESTORY
```

当新建（NEW）一个 Channel 时，它首先会进行初始化（INIT），然后进入路由（ROUTING）阶段，也就是我们查找解析 Dialplan 的阶段。我们称为 Parsing 或 Hunting（传统交换机称为选线，这里我们称为选路），解析完毕后会得到一些 Action，然后进入执行（EXECUTE）阶段，依次执行所有的动作（Action），最后无论哪一方挂机，都会进入（HANGUP）阶段。后面的报告（REPORTING）阶段一般用于进行统计，计费等。最后将 Channel 销毁（DESTORY），释放系统资源。
在 EXECUTE 状态，可能会发生转移（Transfer，非呼叫转移），它可以转移到其他的 extension，此时会重新进入 ROUTING 阶段，重新 Hunting Dialplan。

Extension 中的赋值的临时变量一般情况下在执行（EXECUTE）才会真正去执行，所以在路由（ROUTING）阶段进行解析判断是无法取到赋值后的临时变量的值，我们可以在使用`inline="true"`来使 action 直接执行

```xml
<action inline="true" application="set" data="greeting=hello.wav"/>
```

并不是所有 action 都支持 inline，支持的有

- check_acl
- eval
- event
- export
- enum
- log
- presence
- set
- set_global
- lcr
- set_profile_var
- set_user
- sleep
- unset
- nibblebill
- verbose_events
- cidlookup
- curl
- easyroute
- odbc_quer

inline 会打乱执行顺序，inline 的 action 会先于所有非 inline 的 action 先执行

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

测试中发现呼叫请求服务器处理的特别慢，后来跟踪发现在`/etc/freeswitch/dialplan/default.xml` 中有个 sleep 10s 的处理，

```xml
<condition field="${default_password}" expression="^1234$" break="never">
        <action application="log" data="CRIT WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING "/>
        <action application="log" data="CRIT Open $${conf_dir}/vars.xml and change the default_password."/>
        <action application="log" data="CRIT Once changed type 'reloadxml' at the console."/>
        <action application="log" data="CRIT WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING "/>
        <action application="sleep" data="10000"/>
</condition>
```

我们可以注释掉这个`sleep`，或者修改默认密码，`/etc/freeswitch/`，编译 vars.xml，把默认的密码 1234 改成其他。

```xml
<X-PRE-PROCESS cmd="set" data="default_password=10086"/>
```
