---
title: docker_compose
date: 2019-12-25 23:53:40
categories: docker
tags:
  - docker
  - Dockerfile
---

## 基础

使用`Dockerfile`和`dockder-compose.yml`来定制容器

### `Dockerfile`

```shell
FROM li:tomcat
ENTRYPOINT service ssh start && tail -f /dev/null
```

1. `FROM`表示依赖的镜像
2. `ENTRYPOINT`容器启动后执行的脚本，可用于启动`ssh`服务等

### `docker-compose.yml`

使用配置文件来确定映射的镜像，参考[compose-file](https://docs.docker.com/compose/compose-file/)

```yml
version: "3"
services:
  web:
    build: .
    image: "li:linux"
    ports:
      - "8080:8080"
      - "4022:22"
```

1. `services.web.image`构建的镜像名称
2. `services.web.ports`映射端口
3. `services.web.build`构建的源文件目录
