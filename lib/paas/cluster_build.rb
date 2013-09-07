require 'paas/ruby_core_ext'
require 'paas/shell'
require 'erb'
require 'socket'
require 'net/ssh'
require 'net/scp'
require 'pathname'
require 'logger'

module PaaS

  class ClusterBuild
    include PaaS::Shell
  
    attr_reader :nats_ip, :cc_ip, :uaa_ip

    @@builds = {}

    attr_accessor :script_file

    def self.inherited(build_class)

      build_class.to_s =~ /(.*)Build$/
      name = $1.snake_case
      build_class.name = name
      @@builds[name] = build_class

    end

    def self.find(build_name)
      @@builds[build_name.to_s]
    end

    def self.name
      @name
    end

    def self.name=(name)
      @name = name
    end

    def initialize (config = {})

      @nats_ip = config["nats"]
      @cc_ip = config["cc"]
      @uaa_ip = config["uaa"]

      @ssh_port = "22"
      @ssh_username = "paas"
      @ssh_password = '1qaz@WSX'

      @init_file = $PAAS_HOME + "deploy" + "init.sh"
      @script_file = $PAAS_HOME + "deploy" + "script.sh"

    end

    def generate_script(script_template, context)
      erb = ERB.new(script_template.read)
      script = erb.result(context)
      File.open(script_file, "w") do |file|
        file.write script
      end
    end

    # 同时上传两个文件好像有问题，此处只对文件进行打包，上传压缩文件，解压再执行命令
    def deploy(ip)

      run "tar -cvf #{$PAAS_HOME}/init.tar #{$PAAS_HOME}/deploy"

      Net::SSH.start(ip, @ssh_username, :password => @ssh_password) do |ssh|
        # ssh.scp.upload!(@init_file,'init.sh')
        # ssh.scp.upload!(@script_file,'script.sh')

        # 先搞定sudo输入密码的问题
        # ssh.exec!("sudo ls") do |channel, stream, data|
        # if data =~ /^\[sudo\] password for user:/
        #   channel.send_data @ssh_password
        # end

        stdout = Array.new
        stderr = Array.new

        # 如何判断对方已经有了init.tar
        ssh.scp.upload!("#{$PAAS_HOME}/init.tar","init.tar")
        
        # 执行shell代码  -- 修改为异步执行   防止因为网络问题被中断
        ssh.exec!("tar -xvf init.tar && sh ~#{$PAAS_HOME}/deploy/init.sh && sh ~#{$PAAS_HOME}/deploy/script.sh") do |channel,stream,data|

          stdout << data if stream == :stdout
          stderr << data if stream == :stderr

        end  

        write_log(ip,stdout,stderr)
        # ssh.exec("tar -xvf init.tar && sh ~#{$PAAS_HOME}/deploy/script.sh")
      end
    end

    def write_log(ip, stdout, stderr)

      outfile = Pathname.new($PAAS_HOME + "logs" + "#{ip}_stdout.log")
      errfile = Pathname.new($PAAS_HOME + "logs" + "#{ip}_stderr.log")

      File.open(outfile,"w") do |file|
        file.print(stdout)
      end

      File.open(errfile,"w") do |file|
        file.print(stderr)
      end

    end

    def local_ip(route = '198.41.0.4')
      route ||= '198.41.0.4'
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
      UDPSocket.open {|s| s.connect(route, 1); s.addr.last }
    ensure
      Socket.do_not_reverse_lookup = orig
    end


  end
end  