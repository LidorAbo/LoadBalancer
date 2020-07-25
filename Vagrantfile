# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
webserver1_name = 'webserver1'
webserver2_name = 'webserver2'
load_balancer_name = 'haproxy'
puppet_modules = '/etc/puppet/modules'
modify_vm_string = "modifyvm"
vagrant_modules_path = 'modules'
Vagrant.configure("2") do |config|
  config.vm.box = "aspyatkin/ubuntu-20.04-server"
  config.vm.box_version = "1.0.0"
  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive
    RET=1
    until [ $RET -eq 0 ]; do
        rm -rf /var/lib/apt/lists/* 2> /dev/null
        rm puppet6-release-$(lsb_release -cs).deb  2> /dev/null
        wget -d https://apt.puppetlabs.com/puppet6-release-$(lsb_release -cs).deb
        dpkg -i puppet6-release-$(lsb_release -cs).deb 
        apt-get  update 
        RET=$?
    done 
      apt-get install -y puppet-agent
  SHELL
  config.vm.synced_folder vagrant_modules_path, puppet_modules
  config.vm.define load_balancer_name do |haproxy_config|
    haproxy_config.vm.hostname = load_balancer_name
    haproxy_config.vm.network :private_network, ip: "10.0.0.2"
    haproxy_config.vm.provider :virtualbox do |vb|
      vb.customize [modify_vm_string, :id, "--memory", "4096"]
      vb.customize [modify_vm_string, :id, "--cpus", "2"]
    end
    
  end
  config.vm.define webserver1_name do | webserver1_config|
    webserver1_config.vm.hostname = webserver1_name
    webserver1_config.vm.network :private_network, ip: "10.0.0.3"
  end
  config.vm.define webserver2_name do | webserver2_config|
    webserver2_config.vm.hostname = webserver2_name
    webserver2_config.vm.network :private_network, ip: "10.0.0.4"
  end
    config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path    = vagrant_modules_path
    puppet.manifest_file  = "site.pp"    
  end
end
