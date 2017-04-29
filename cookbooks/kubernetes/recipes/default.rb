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

service 'flanneld' do
  action [:enable, :restart]
end

service 'kube-apiserver' do
    action [:enable, :restart]
end
