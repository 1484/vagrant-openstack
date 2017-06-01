Vagrant.configure('2') do |config|
  config.vm.boot_timeout = 1000000
  config.ssh.private_key_path = '~/.ssh/azure'
  config.vm.box = 'azure'

  do_common_azure_stuff = Proc.new do |azure, override|
#    override.config.vm.box = 'azure'

    azure.tenant_id = ENV['AZURE_TENANT_ID']
    azure.client_id = ENV['AZURE_CLIENT_ID']
    azure.client_secret = ENV['AZURE_CLIENT_SECRET']
    azure.subscription_id = ENV['AZURE_SUBSCRIPTION_ID']
    azure.location = 'westus2'

  end

config.vm.define 'controller' do |cfg|
  cfg.vm.provider :azure do |azure, override|
    do_common_azure_stuff.call azure, override
      azure.vm_name = 'controller'
      azure.vm_image_urn = 'canonical:ubuntuserver:16.04-LTS:16.04.201705080'
      azure.vm_size = 'Standard_DS2_v2'
      azure.virtual_network_name = 'openstack-dev'
      azure.subnet_name = 'openstack-dev'
      azure.resource_group_name = 'openstack-dev'
      azure.tcp_endpoints = '80'
    end
      cfg.vm.network :private_network, ip: "10.0.0.4", type: "dhcp"
#      cfg.vm.network :forwarded_port, guest: 80, host: 80, protocol: "tcp", host_ip: "empty"
      cfg.vm.provision 'shell', path: 'shell/controller.sh'
  end

config.vm.define 'compute' do |cfg|
  cfg.vm.provider :azure do |azure, override|
    do_common_azure_stuff.call azure, override
      azure.vm_name = 'compute'
      azure.vm_image_urn = 'canonical:ubuntuserver:16.04-LTS:16.04.201705080'
      azure.vm_size = 'Standard_DS2_v2'
      azure.virtual_network_name = 'openstack-dev'
      azure.subnet_name = 'openstack-dev'
      azure.resource_group_name = 'openstack-dev'
    end
      cfg.vm.network :private_network, ip: "10.0.0.5", type: "dhcp"
      cfg.vm.provision 'shell', path: 'shell/controller.sh'
  end

 end

