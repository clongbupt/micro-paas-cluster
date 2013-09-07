require 'paas/control'

class DirectoryServerControl < PaaS::Control 
  def start
    if process_exist? pid_file
      puts "directory_server already running, pid is #{get_pid(pid_file)}"
      return
    end

    run "rm #{pid_file}"

    run "#{@release_dir}/dea_ng/go/bin/runner -conf #{@vcap_sys_config}/dea_ng.yml >>#{vcap_sys_log}/directory_server.stdout.log 2>>#{vcap_sys_log}/directory_server.stderr.log &"
    system "ps -ef | grep runner | grep -v grep | awk '{print $2}' > #{vcap_sys_run}/directory_server.pid"
  end
end
