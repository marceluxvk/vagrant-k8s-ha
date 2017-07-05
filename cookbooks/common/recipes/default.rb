link '/etc/localtime' do
  to '/usr/share/zoneinfo/America/Sao_Paulo'
end

cookbook_file '/etc/selinux/config' do
  source 'selinux'
  owner 'root'
  group 'root'
  mode '0644  '
  action :create
end

execute 'setenfore' do
  command 'setenforce 0'
  action :run
end

service 'firewalld' do
  action [:disable, :stop]
end

package 'epel-release' do
  action :install
end

group 'docker' do
  members 'vagrant'
  action :create
  append true
end

group 'wheel' do
  members 'vagrant'
  action :modify
  append true
end

package ['nss-mdns', 'net-tools', 'docker'] do
  action :install
end

cookbook_file '/etc/avahi/avahi-daemon.conf' do
  source 'avahi-daemon.conf'
  owner 'root'
  group 'root'
  mode '0644  '
  action :create
end

service 'avahi-daemon' do
  action [:enable, :restart]
end

cookbook_file '/etc/docker/daemon.json' do
  source 'docker_daemon.json'
  mode '0664'
  action :create
end

cookbook_file '/etc/sysconfig/docker' do
  source 'docker'
  mode '0644'
  action :create
end

service 'docker' do
  action [:enable, :restart]
end

