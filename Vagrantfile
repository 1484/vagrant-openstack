# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  config.vm.define :controller do | controller |
    controller.vm.hostname = "controller"
    controller.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 4192]
    end
    controller.vm.network :private_network, ip: "10.0.0.101", virtualbox__intnet: "intnet"
    controller.vm.network :forwarded_port, guest: 80, host: 8880, protocol: "tcp", host_ip: "empty"
    controller.vm.provision "shell", path: "shell/controller.sh"
  end

  config.vm.define :compute do | compute |
    compute.vm.hostname = "compute"
    compute.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", 2048]
    end
    compute.vm.network :private_network, ip: "10.0.0.102", virtualbox__intnet: "intnet"
    compute.vm.provision "shell", path: "shell/compute.sh"
  end
end
