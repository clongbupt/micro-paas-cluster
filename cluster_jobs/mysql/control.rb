require 'paas/control'

class MysqlControl < PaaS::Control

  def reset_config
    # 因为配置文件不是*.yml格式 此处覆盖父类的config_file
    @config_file = vcap_sys_config + "my.cnf"
  end

  # 默认当前路径为package目录？
  def start 
    reset_config
    
    first = File.exist? @config_file
    
    config_template = current_dir(__FILE__) + "my.cnf.erb"
    generate_config(config_template, binding)
  
    init(@config_file) if !first
	
    cd package_dir do 
      run "bin/mysqld --defaults-file=#{config_file} --user=#{ENV['USER']} --basedir=#{package_dir}  --datadir=#{vcap_sys_data + "mysql"} &"
    end
  end

  def stop
    reset_config

    cd package_dir do 
      run "bin/mysqladmin --defaults-file=#{config_file} -u root shutdown"
    end
  end

  def status
    reset_config
    
    cd package_dir do
      run "bin/mysqladmin --defaults-file=#{config_file} status"
    end
  end

  def restart
    stop
	  start
  end
  
  def init config_file
    
    mysql_data_dir = vcap_sys_data + "mysql"
  
    cd package_dir do
  
      # 初始化数据库, 此处一定要加上datadir否则会初始化到默认位置
      run "scripts/mysql_install_db --user=#{ENV['USER']} --datadir=#{mysql_data_dir} --basedir=#{package_dir}"
      
      # 数据库配置文件
      # run "cp support-files/my-medium.cnf #{config_file}"
      
      # mysql默认安装只监听127.0.0.1默认地址，这里修改为监听所有ip
      run "sudo sed -i 's/127.0.0.1/0.0.0.0/g' #{config_file}"
    
      # 后台启动mysql
      run "bin/mysqld --defaults-file=#{config_file} --user=#{ENV['USER']} --basedir=#{package_dir} --datadir=#{mysql_data_dir} &"
      
      sleep 4
      
      # mysql默认root只能从本机登录，这里修改为允许从所有服务器使用root登录
      run "echo \"grant all privileges on *.* to root@'%' identified by 'mysql' with grant option;\" | bin/mysql --defaults-file=#{config_file} -u root --password='' mysql "
      
      # 关闭mysql
      run "bin/mysqladmin --defaults-file=#{config_file} -u root shutdown"
      
      # 设置mysql自启动
      # run "sudo cp support-files/mysql.server /etc/init.d/mysql"
      # run "sudo chkconfig --add mysql"
      # run "sudo chconfig mysql on"
    end
  
  end

end
