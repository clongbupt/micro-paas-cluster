#!bin/bash

## 配置mysql_gateway

# 修改nats_ip
sed -i "s/mbus: nats:\/\/<\%\= local_ip %>:4222\//mbus: nats:\/\/10.1.59.161:4222\//g" /home/paas/paas-release.git/jobs/mysql_gateway/mysql_gateway.yml.erb

# 修改uaa_ip
sed -i "s/uaa_endpoint: http:\/\/<\%\= local_ip %>:8080\/uaa/uaa_endpoint: http:\/\/10.1.59.253:8080\/uaa/g" /home/paas/paas-release.git/jobs/mysql_gateway/mysql_gateway.yml.erb

# 修改cc_ip
sed -i "s/cloud_controller_uri: http:\/\/<\%\= local_ip%>:8181/cloud_controller_uri: http:\/\/10.1.59.253:8181/g" /home/paas/paas-release.git/jobs/mysql_gateway/mysql_gateway.yml.erb


## 配置mysql_node

# 修改@nats_ip
sed -i "s/mbus: nats:\/\/<\%\= local_ip %>:4222/mbus: nats:\/\/10.1.59.161:4222/g" /home/paas/paas-release.git/jobs/mysql_node/mysql_node.yml.erb

# 修改mysql_node_free_1
sed -i "s/node_id:\ mysql_node_free_1/node_id:\ mysql_node_free_1/g" /home/paas/paas-release.git/jobs/mysql_node/mysql_node.yml.erb

# 修改index
sed -i "s/index: 0/index: 0/g" /home/paas/paas-release.git/jobs/mysql_node/mysql_node.yml.erb


## 启动命令

# 启动redis
/home/paas/paas-release.git/bin/paas redis start

# 启动mysql_gateway
/home/paas/paas-release.git/bin/paas mysql_gateway start

# 启动mysql_node
/home/paas/paas-release.git/bin/paas mysql start

/home/paas/paas-release.git/bin/paas mysql_node start