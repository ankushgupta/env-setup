# Cookbook Name:: nagios_nrpe
# Recipe:: centos
#
# Copyright 2012
#
# All rights reserved - Do Not Redistribute

["nrpe", "nagios-plugins-nrpe", "nagios-plugins-all"].each do |pkg|
  package pkg
end

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nrpe.d/system.cfg" do
  source "system.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[nrpe]"; :immediately
end

["check_jenkins","check_apache","check_tomcat","check_postgresql","check_inode", "check_memory", "check_space", "check_procs"].each do |file|
  cookbook_file "/usr/lib64/nagios/plugins/#{file}" do
    source file
    owner "root"
    group "root"
    mode "755"
    notifies :restart, "service[nrpe]"; :immediately
  end
end

#execute "open port for nagios" do
#  command "iptables -I INPUT -p tcp -m tcp --dport 5666 -j ACCEPT"
#  action :run
#end

service "nrpe" do
  supports :restart => true
  action [:enable, :start]
  
  start_command "/usr/sbin/nrpe -c /etc/nagios/nrpe.cfg -d"
  stop_command "service nrpe stop"
  restart_command "service nrpe stop; /usr/sbin/nrpe -c /etc/nagios/nrpe.cfg -d"
end
