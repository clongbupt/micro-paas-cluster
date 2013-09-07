#!bin/bash

# 修改ubuntu下当前普通用户执行sudo的权限 不用输入密码
sudo chmod +w /etc/sudoers
sudo sh -c "echo '$USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo chmod -w /etc/sudoers

# 更新
sudo sed -i "s/cn.archive.ubuntu.com/mirrors.sohu.com/g" /etc/apt/sources.list

# 注释掉security部分
sudo sed -i "/security.ubuntu.com/s/^/# &/g" /etc/apt/sources.list

sudo apt-get update
sudo apt-get -y install git wget zip
sudo apt-get -y install ruby1.9.3

# 下载build_dir的绿色包，解压后删除原始下载包
wget http://file.ebcloud.com/micro-paas/micro-paas-0.1.2_build_dir.tar.gz
tar zxvf micro-paas-0.1.2_build_dir.tar.gz
rm micro-paas-0.1.2_build_dir.tar.gz 

# 修复1.0.2 build_dir中的一个链接错误
cd build_dir/target
rm redis
ln -s redis-2.6.13/ redis
cd $HOME

# 下载paas-release
git clone http://paasbuild:helloebupt@git.ebcloud.com/paas/paas-release.git paas-release.git
cd paas-release.git
git checkout -b 0.1.2 0.1.2 

# 初始化paas，在paas-release.git目录下执行如下命令
bin/environment
source ~/.bashrc

# 重新下载rootfs
bin/paas-build rootfs

# 后面可能需要移除整体启动和关闭的命令 启动单个组件即可
# 不过得考虑单组件的问题
bin/pre-paas