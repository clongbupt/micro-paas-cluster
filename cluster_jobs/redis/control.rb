require 'paas/control'

class RedisControl < PaaS::Control

  # 默认当前路径为package目录？
  def start 
  
    # 因为配置文件不是*.yml格式 此处覆盖父类的config_file
    @config_file = vcap_sys_config + "redis.cnf"
    
    first = File.exist? @config_file
    
    port = "5454"
    
    config_template = current_dir(__FILE__) + "redis.conf.erb"
    generate_config(config_template, binding)
  
    cd package_dir do
      run "./redis-server #{@config_file}"
    end
  end

  def stop
    cd package_dir do 
      run "./redis-cli -p 5454 shutdown"
    end
  end

  def restart
    stop
    sleep 2
    start
  end
=begin
  def status
    run "ps -ef | grep redis-server"
  end
=end
end
