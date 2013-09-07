require 'paas/cluster_build'

class HealthManagerBuild < PaaS::ClusterBuild 

  # 默认当前路径为package目录？
  def start args

    # 远程登录服务器上传文件
    ips = args["ip"]
    
    if ips.is_a? Array
      ips.each_index do |index|

        # 生成修改hm配置文件的脚本
        script_template = current_dir(__FILE__) + "health_manager.sh.erb"
        generate_script(script_template, binding)

        deploy(ips[index])
      end
    else
      puts "config/cluster.yml file error, please ensure that every ip is an array"
    end  
  end

end
