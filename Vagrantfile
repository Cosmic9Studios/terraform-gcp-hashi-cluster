# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.network "forwarded_port", guest: 9000, host: 9000, host_ip: "127.0.0.1"
    config.vm.network "private_network", ip: "192.168.50.50"
    config.vm.synced_folder "./modules/packer/salt", "/srv/salt/", type: "rsync"

    config.vm.provision :salt do |salt|
        salt.masterless = true
        salt.minion_config = "modules/packer/salt/minion"
        salt.run_highstate = true
        salt.salt_call_args = ["saltenv=client"] 
    end

    config.vm.provision :salt do |salt|
        salt.masterless = true
        salt.minion_config = "modules/packer/salt/minion"
        salt.run_highstate = true
        salt.salt_call_args = ["saltenv=server"] 
    end
end
