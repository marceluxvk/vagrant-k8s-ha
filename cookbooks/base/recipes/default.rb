package ['etcd', 'haproxy'] do
  action :install
end

cookbook_file '/etc/etcd/etcd.conf' do
  source 'etcd.conf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

service 'etcd' do
  action [:enable, :start]
end

template '/etc/haproxy/haproxy.cfg' do
  source 'haproxy.cfg.rb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

script 'etcd_configuration' do
  interpreter 'bash'
  code <<-EOF
    docker run -d -p 5000:5000 --restart always registry:2
    etcdctl mkdir /kubecluster/network
    etcdctl mk /kubecluster/network/config "{\"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\"}}"
    touch /usr/local/etcd.ok
    EOF
  action :run
  not_if {::File.exist?('/usr/local/etcd.ok')}
end

service 'haproxy' do
  action [:enable, :restart]
end

