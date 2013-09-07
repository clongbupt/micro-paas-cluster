paas-release的多机部署项目, 基于paas-release项目开发。

## 多机部署代码架构

执行代码: `paas-release-cluster.git/bin/paas-cluster-build`

主要做如下几个工作：

	1. 解析集群部署的配置文件
	2. 解析入口参数   支持修改配置文件位置和单个服务器组件的部署
	3. 根据配置文件依次部署各个组件

集群部署的配置文件  `paas-release-cluster.git/config/cluster.yml`

主要分为三块位置: 

	1. 顶部的nats, uaa, cc三个组件的IP，属于全局范围的参数，其他组件也会用到，所以单独列出，不过需要于下面的nats的ip保持一致

	2. components数组  这个部署列表   标明了所有的组件及其部署顺序

	3. server 为所有的组件部署信息   后面会根据每一个组件的信息去一一部署该组件

示例如下:

	---
	nats: 10.1.59.160
	uaa: 10.1.59.187
	cc: 10.1.59.180

	components:
	  - nats
	  - router
	  - postgres
	  - uaa
	  - cloud_controller_ng
	  - health_manager
	  - dea_ng
	  - mysql_gateway
	  - mysql_node


	server:
	  nats:
	    ip: 
	      - 10.1.59.160

	  router:
	    ip:
	      - 10.1.59.188
	      - 10.1.59.172

	  postgres:
	    ip:
	      - 10.1.59.174

	  uaa:
	    ip: 
	      - 10.1.59.187

	  cloud_controller_ng:
	    ip: 
	      - 10.1.59.180

	  health_manager:
	    ip: 
	      - 10.1.59.163

	  dea_ng:
	    ip:
	      - 10.1.59.170
	      - 10.1.59.184

	  mysql_gateway:
	    ip:
	      - 10.1.59.175

	  mysql_node:
	    ip:
	      - 10.1.59.175
	      - 10.1.59.176

集群部署的父类 `paas-release-cluster.git/lib/paas/cluster_build.rb`

	1. 维护从配置文件中读取的或者内部定义的暂时不变的变量：

		@nats_ip = config["nats"]
		@cc_ip = config["cc"]
		@uaa_ip = config["uaa"]

		@ssh_port = "22"
		@ssh_username = "paas"
		@ssh_password = '1qaz@WSX'

		@init_file = $PAAS_HOME + "deploy" + "init.sh"
		@script_file = $PAAS_HOME + "deploy" + "script.sh"

	2. 生成组件特定的脚本文件

		需要子类配置实现

	3. 部署特定组件 需要预先在客户端安装好gem包 net-ssh 和 net-scp

		通过调用net-ssh和net-scp方法可以远程连接目标服务器， 上传脚本， 并执行脚本

特定组件的集群部署类 如nats的build文件 `paas-release-cluster.git/cluster_jobs/nats/build.rb`
		
	主要是start方法，取出配置文件的参数，根据这些参数和每个组件的情况，生成特定组件的执行脚本

特定组件的执行脚本  `paas-release-cluster.git/cluster_jobs/nats/nats.sh.erb`

	主要是修改该服务器下的组件的配置文件，使其可以成为集群的一部分
	另外是对特定组件的启动， 某些组件，如dea需要先启动warden才能启动，也可以在此处处理

	# 修改ip
	sed -i 's/net:\ 0.0.0.0/net:\ <%= @nats_ip %>/g' /home/paas/paas-release.git/nats/jobs/nats.yml.erb

	# 启动nats组件
	paas-release.git/bin/paas nats start


## 编写笔记

### 2013/7/27

gem install net-ssh net-scp 通过它们来登录远程服务器并下载文件

如何解决config的问题

直接生成shell脚本
然后用公用脚本调用特殊脚本

公用脚本主要是进行环境的初始化

特殊脚本是每个组件自己的， 主要是修改自己的配置文件  以及 启动该组件


### 2013/7/28

主要问题在如何消除sudo方法

通过expect方法?

最后通过制作了一个不需要sudo密码的ubuntu纯净盘解决

后面可以进一步完善

### 2013/7/30

由于各个服务器都是全组件安装，那么可以通过增加cluster_jobs的方式，更加灵活的增加和修改服务器部署

比如： 将uaa+cc+postgres部署在一起，那么只需要增加

uaa\_cc\_postgres目录
并修改uaa\_cc\_postgres.sh.erb  将uaa目录/cc目录/postgres目录各自的sh.erb文件进行整合即可

同时修改cluster.yml文件

将文件中的components域和server域进行相应的更新， 如：

	uaa: 10.1.59.*
	cc: 10.1.59.*

	components:
	  - uaa_cc_postgres

	server
      uaa_cc_postgres:
        ip:
          - 10.1.59.*


### 2013/7/31

部署方案一：  

目的：

	* 简化postgres的调试   
	* 减少测试机器的数量

各个组件分配情况:

	nats + router + health_manager

	postgres + uaa + cc

	dea + warden + directory

	mysql_gateway + mysql_node

	
### 2013/8/4

TODO

增加对服务器部署程度的判断  ：  

	如果该服务器以前部署过micro_paas则可以忽略掉init脚本

	如果没有则需要执行init脚本


执行完后是否需要将部署脚本删除
