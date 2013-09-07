
module PaaS

  module Shell

    class << self
      attr_accessor :exit_when_failed
    end

    # 执行shell命令
    def run(command, opts = {})
      command = "#{opts[:sudo]} #{command}" if opts[:sudo]

      blue "---> run [#{command}]"
      system command

      if $?.exitstatus == 0 
        puts "---> exitcode = #{$?.inspect}"
      else 
        red "---> exitcode = #{$?.inspect}"
        if Shell.exit_when_failed
          exit
        end
      end
      $?.exitstatus
    end

    def red(str)
      puts "\033\[49;31;1m#{str}\033[0m"
    end

    def blue(str)
      puts "\033\[49;34;1m#{str}\033[0m"
    end

    def cd(path, &block)
      begin 
        current_dir = Dir.pwd if block
        chdir(path)
        block.call if block
      ensure
        chdir(current_dir) if current_dir
      end
    end

    def chdir(dir)
      blue("---> run [cd #{dir}]")
      Dir.chdir(dir)
    end
  
    def current_dir(current_file)
      Pathname.new(File.dirname(current_file)).realpath
    end

    def ruby(cmdline, opts = {})
      run("#{release_dir}/ruby/bin/ruby #{cmdline}", opts)
    end

    def bundle_install(without = true)
      auto_replace_gem_source
      command = "#{release_dir}/ruby/bin/bundle install "
      command += "--without development test" if without
      ruby command
    end

    def gem_install(package)
      ruby "#{release_dir}/ruby/bin/gem install #{package}"
    end

    def auto_replace_gem_source
      run "sed -i 's/rubygems.org/ruby.taobao.org/g' Gemfile"
    end

    def bundle_exec(cmd, opts = {})
      ruby "#{release_dir}/ruby/bin/bundle exec #{release_dir}/ruby/bin/ruby #{cmd}", opts
    end

    def bundle_exec_rake(cmd, opts = {})
      bundle_exec("#{release_dir}/ruby/bin/rake #{cmd}", opts)
    end

    def release_dir
      @release_dir
    end

    def pg_start()
      run("LD_LIBRARY_PATH=#{release_dir}/postgres/lib #{release_dir}/postgres/bin/pg_ctl start -D #{release_dir}/postgres/data")
    end

    def psql(cmdline)
      run("#{release_dir}/postgres/bin/psql #{cmdline}")
    end

    def java(cmdline)
      run("#{release_dir}/java/bin/java #{cmdline}")
    end

    def mvn(cmdline)
      set_sys_env("JAVA_HOME", "#{release_dir}/java")
      run("#{release_dir}/maven/bin/mvn #{cmdline}")
    end

    def set_sys_env(name, value)
      ENV[name.to_s] = value.to_s
    end

    def set_sys_path(name)
      ENV["PATH"] = ENV["PATH"] + ":" + name
    end

  end
end
