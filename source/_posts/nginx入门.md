---
title: nginx入门
date: 2020-06-19 19:20:42
categories: linux
tags:
  - nginx
---

## 安装

基于 centos

1. 安装依赖工具
   `sudo yum install yum-utils`
2. 配置 yum 的源
   新建文件`/etc/yum.repos.d/nginx.repo`，并写入以下内容

   ```properties
   [nginx-stable]
   name=nginx stable repo
   baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
   gpgcheck=1
   enabled=1
   gpgkey=https://nginx.org/keys/nginx_signing.key
   module_hotfixes=true

   [nginx-mainline]
   name=nginx mainline repo
   baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
   gpgcheck=1
   enabled=0
   gpgkey=https://nginx.org/keys/nginx_signing.key
   module_hotfixes=true
   ```

3. 若需要安装最新版，而非调试版本
   `sudo yum-config-manager --enable nginx-mainline`
4. 安装 nginx
   `sudo yum install nginx`

## 启动

nginx 有一个 master 线程和多个 worker 进程，master 进程用来读取，解析配置文件以及管理 worker 进程，worker 进程才是真正处理请求的进程。worker 进程的个数可通过配置文件去配置或自动设置为 cpu 的核心数。可通过修改配置设定

```nginx
worker_processes 1;
```

使用`nginx`即可启动,一旦 nginx 启动，就可以使用如下命令去控制 nginx

> nginx -s signal

- stop — fast shutdown
- quit — graceful shutdown
- reload — reloading the configuration file
- reopen — reopening the log files

当更改配置文件后，可以使用`nginx -s reload`，使配置文件生效。
当 master 进程接收到 reload 的信号后，它首先会校验配置文件语法是否正确然后才会接收新的配置文件，若配置文件修改成功，master 进程会启动新的 worker 进程，并向旧的 worker 进程发送停止命令，旧的 worker 进程会以旧的配置处理请求，在处理完旧的请求后便会退出。

## 配置

### 可用变量

[官方文档可用变量](http://nginx.org/en/docs/http/ngx_http_core_module.html#variables)

常用变量

- `$arg_<name>` url 请求请求参数 name 的值
- `$query_string` url 整个请求参数字符串，即`?`后面的参数,例如:`a=1&b=2`
- `$upstream_http_<header>` 返回报文的头,header 请求头的名称
- `$http_<header>` 请求报文的头,header 请求头的名称

### 配置文件结构

nginx 的配置文件名为 nginx.conf,一般位于目录/usr/local/nginx/conf, /etc/nginx, 或 /usr/local/etc/nginx.下
nginx 的组件由配置文件中的指令构成，指令的基本格式有两种

1. 简单的命令：由 name 和 parameters 以及`；`结尾
2. 块命令： 由 name 和一个由大括号`{}包裹的命令的集合，同时也被称为 context
3. \#后面的视为注释
4. 不在任何 context 内的命令则被视为在 [main context](http://nginx.org/en/docs/ngx_core_module.html)中

## 监听请求

我们通过配置[server](http://nginx.org/en/docs/http/ngx_http_core_module.html#server)来处理请求

例如：

```nginx
server {
    listen      80;
    server_name example.org www.example.org;
    ...
}

server {
    listen      80;
    server_name example.net www.example.net;
    ...
}

server {
    listen      80;
    server_name example.com www.example.com;
    ...
}
```

其中`port`表示监听的端口号，`server_name`表示监听的`host`（即 IP 地址或域名地址），server_name 与 host 匹配的优先级关系如下

1. 完全匹配
2. 通配符在前的，如\*.test.com
3. 在后的，如 www.test.\*
4. 正则匹配，如~^\.www\.test\.com\$

如果都不匹配

1. 优先选择 listen 配置项后有 default 或 default_server 的
2. 找到匹配 listen 端口的第一个 server 块

通过`curl -v`，我们可以看到 host

## 处理请求

在[server](http://nginx.org/en/docs/http/ngx_http_core_module.html#server)下配置[location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)

1. `location = /uri` 　　　`=`开头表示精确匹配，只有完全匹配上才能生效。
2. `location ^~ /uri` 　　`^~` 开头对 URL 路径进行前缀匹配，并且在正则之前。
3. `location ~ pattern` 　`~`开头表示区分大小写的正则匹配。
4. `location ~* pattern` 　`~*`开头表示不区分大小写的正则匹配。
5. `location /uri` 　　　　不带任何修饰符，也表示前缀匹配，但是在正则匹配之后。
6. `location /` 　　　　　通用匹配，任何未匹配到其它 location 的请求都会匹配到，相当于 switch 中的 default。

### 映射静态资源

root 指向静态资源的路径
index 默认首页

```nginx
server {
   listen 8888;
   server_name "test";
   location ~ \.(gif)$ {
         root /home/li/tomcat/webapps/manager;
         index index.html;
   }
}
```

### 增加请求头

配置，这样在服务器端的 headers 中就可以看到名为 name 的指定 header，需要注意的是，当值为空时，nginx 不会发送该请求头

```nginx
server {
   listen 18080;
   location / {
      proxy_pass http://f5;
      proxy_set_header name $arg_name;

   }
}
```

## 负载均衡

### 测试用脚本

一个测试用的 http 服务端程序

```python
# --coding:utf-8--

from http.server import BaseHTTPRequestHandler, HTTPServer
from os import path
import sys
from urllib.parse import urlparse

port = 8081
class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        global port
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.send_header('port', port)
        self.end_headers()
        self.wfile.write(b'')
        print(port,self.headers.get('Host'), self.path,flus
h=True)

    def do_POST(self):
        self.do_Get()


def run():
    if len(sys.argv) > 1:
        global port
        port = int(sys.argv[1])
        print('port',port)
    server_address = ('', port)
    httpd = HTTPServer(server_address, Handler)
    print('running server...', port)
    httpd.serve_forever()


if __name__ == '__main__':
    run()

```

启动多个 http 服务的 shell 脚本

```shell
start(){
 echo 'start'$1
 python http_nginx.py  $1 >> nginx.log  2>&1 &
 echo "kill -9 $! # $1" >> nginx.pid
}
stop(){
echo 'stop'
ps -ef|grep http_nginx|grep -v grep|grep -v start|awk '{print "kill -
9 "$2}'|sh
}

stop
touch nginx.log
touch nginx.pid
:>nginx.log
:>nginx.pid

args=$@
if [ ! -n "$args" ] ;then
  args='18081 18082 18083'
fi
for arg in $args
do
  start $arg &
done

tail -f nginx.log

```

### 负载均衡与 session 保持

```nginx
upstream f5 {

   hash $arg_a;
   server localhost:18081;
   server localhost:18082;
   server localhost:18083;
}
server {
   listen 18080;
   location / {
      proxy_pass http://f5;

      }
}

```

使用测试脚本不断访问

```shell
while [ 1 ]
do
curl localhost:18080/hello?a='123456&b=abc'
sleep 1
done
```

通过观察 http 服务端的日志输出，我们可以发现所有请求都指向了同一个服务器

当请求 url 不带参数`a`时，可以观察到所有请求均衡的分配在每台服务器上

> 18082 f5 /hello
> 18081 f5 /hello?a=123456&b=abc
> 18083 f5 /hello
> 18081 f5 /hello?a=123456&b=abc
> 18081 f5 /hello
> 18082 f5 /hello
> 18081 f5 /hello?a=123456&b=abc
> 18083 f5 /hello
> 18081 f5 /hello?a=123456&b=abc

**_当负载服务器停止服务时，nginx 会自动重新计算 hash_**

## 日志

我们可配置`http|log_format`来控制 nginx 的 access_log 日志的输出内容,你可以打印所有 nginx 中有关的变量值

```nginx
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" ' '$status $body_bytes_sent "$http_referer" ''"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
}
```

## 禁用浏览器缓存

通过添加返回头

```nginx
server {
    listen      80;
    server_name example.org www.example.org;

    # 设置禁用浏览器缓存
    add_header Cache-Control no-cache;
    ...
}
```
