Vagrant.configure('2') do |config|
    numberOfNodes=2

    kubelets = Array.new(numberOfNodes)
    (1..numberOfNodes).each do |id|
        kubelets[id - 1] = "kube#{id}"
    end

    config.vm.box = "centos/7"
    config.vm.network "private_network", type: "dhcp"
    config.vm.provision "chef_solo" do |chef|
        chef.add_recipe "common"
    end

    config.vm.provider 'virtualbox' do |vb|
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.memory = '1024'
    end
    
    config.vm.define 'base' do |server|
      server.vm.hostname = "base.local"
      server.vm.synced_folder '.', '/vagrant', type: 'virtualbox'
      server.vm.provision "chef_solo" do |chef|
        chef.add_recipe "base"
        chef.json = {
            "kubelets": kubelets
        }
      end
    end

    (1..numberOfNodes).each do |host|
        config.vm.define "kube#{host}" do |server|
            server.vm.hostname = "kube#{host}.local"
            server.vm.synced_folder '.', '/vagrant', type: 'virtualbox'
        end
    end
end