cookbook_file '/etc/yum.repos.d/virt7-docker-common-release.repo' do
  source 'virt7-docker-common-release.repo'
  mode '0644'
  action :create
end

package ['kubernetes', 'flannel'] do
  action :install
end

cookbook_file '/etc/kubernetes/config' do
  source 'kube_config'
  mode '0644'
  action :create
end

cookbook_file '/etc/kubernetes/apiserver' do
  source 'apiserver'
  mode '0644'
  action :create
end

cookbook_file '/etc/sysconfig/flanneld' do
  source 'flanneld.conf'
  mode '0644'
  action :create
end

cookbook_file '/usr/lib/systemd/system/kube-apiserver.service' do
  source 'kube-apiserver.service'
  owner 'root'
  group 'root'
  mode '644'
  action :create
end

cookbook_file '/etc/kubernetes/controller-manager' do
  source 'controller-manager'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

cookbook_file '/etc/kubernetes/scheduler' do
  source 'scheduler'
  owner 'root'
  group 'root'
  mode '644'
  action :create
end

template '/etc/kubernetes/proxy' do
  source 'proxy.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

template '/etc/kubernetes/kubelet' do
  source 'kubelet.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

service 'flanneld' do
  action [:enable, :restart]
end

service 'kube-apiserver' do
    action [:enable, :restart]
end

service 'kube-controller-manager' do
  action [:enable, :restart]
end

service 'kube-scheduler' do
  action [:enable, :restart]
end

service 'kube-proxy' do
  action [:enable, :restart]
end

service 'kubelet' do
  action [:enable, :restart]
end

script 'habilita kubectl no master' do
  interpreter 'bash'
  code <<-EOF
  kubectl config set-cluster default-cluster --server=http://base.local:8080
  kubectl config set-context default-context --cluster=default-cluster --user=default-admin
  kubectl config use-context default-context
  EOF
end