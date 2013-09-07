#!/usr/bin/env ruby
# coding : UTF-8

require "net/ssh"

# 连接到远程主机 foobar
ssh = Net::SSH.start("10.1.59.162", "paas", :password => "1qaz@WSX") do |ssh|

  # 先搞定sudo输入密码的问题
  ssh.exec!("sudo ls") do |channel, stream, data|
    puts data.inspect
    if data =~ /^\[sudo\] password for paas:/
      channel.send_data '1qaz@WSX'
    else
      puts data.inspect
    end
  end

end
