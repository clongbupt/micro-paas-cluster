require 'paas/control'

class WardenControl < PaaS::Control 

  # 默认当前路径为package目录？
  def start 
    if process_exist? pid_file
      puts "warden already running, pid is #{get_pid(pid_file)}"
      return 
    end

    log_file = vcap_sys_log + "warden.log"

    rootfs_path = $HOME + "#{release_dir}/rootfs"
    container_path = $HOME +  "warden/container"

    [rootfs_path, container_path].each { |d| d.mkpath }

    config_template = current_dir(__FILE__) + "warden.yml.erb"
    generate_config(config_template, binding)

    cd "#{package_dir}/warden" do
      bundle_exec_rake "--trace warden:start[#{config_file}] >>#{vcap_sys_log}/warden.stdout.log 2>>#{vcap_sys_log}/warden.stderr.log &", :sudo => "sudo"
    end
  end

  def client_start
    # TODO 判断存在问题 最好用pid_file进行判断
    if File.exist? @config_file
      ruby "#{package_dir}/warden/bin/warden"
    else
      puts "warden is not running, please run warder server first"
      return 
    end
  end

  def stop
    stop_it("sudo")
  end

end
