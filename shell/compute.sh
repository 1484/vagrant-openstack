#!/bin/sh
sudo cp /vagrant/settings/hosts /etc
sudo add-apt-repository cloud-archive:newton -y
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install chrony -y
sudo sed -i "s/pool 2.debian.pool.ntp.org offline iburst/#pool ntp.nict.jp offline iburst/g" /etc/chrony/chrony.conf
sudo sh -c "echo 'server controller iburst' >> /etc/chrony/chrony.conf"
sudo service chrony restart
sudo apt-get install nova-compute -y
sudo sed -i "s/^enabled_apis=ec2,osapi_compute,metadata/enabled_apis = osapi_compute,metadata/" /etc/nova/nova.conf
sudo sed -i "s/^\[DEFAULT\]/\[DEFAULT\]\ntransport_url = rabbit:\/\/openstack:password@controller\nauth_strategy = keystone\nuse_neutron = True\nfirewall_driver = nova.virt.firewall.NoopFirewallDriver\nmy_ip = 10.0.0.102\n/" /etc/nova/nova.conf
sudo sh -c "cat <<'EOF'>>/etc/nova/nova.conf
[vnc]
enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = \$my_ip
novncproxy_base_url = http://controller:6080/vnc_auto.html

[glance]
api_servers = http://controller:9292
[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = password

[oslo_concurrency]
lock_path = /var/lib/nova/tmp
EOF"
sudo sed -i "s/^virt_type=kvm/virt_type=qemu/" /etc/nova/nova-compute.conf
sudo service nova-compute restart
sudo apt-get install neutron-linuxbridge-agent -y
sudo sed -i "s/^\[DEFAULT\]/\[DEFAULT\]\nrpc_backend = rabbit\nauth_strategy = keystone\n/" /etc/neutron/neutron.conf
sudo sed -i "s/^\[oslo_messaging_rabbit\]/\[oslo_messaging_rabbit\]\nrabbit_host = controller\nrabbit_userid = openstack\nrabbit_password = password\n/" /etc/neutron/neutron.conf

sudo sed -i "s/^\[keystone_authtoken\]/\[keystone_authtoken\]\nauth_uri = http:\/\/controller:5000\nauth_url = http:\/\/controller:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nproject_name = service\nusername = neutron\npassword = password\n/" /etc/neutron/neutron.conf
sudo sed -i "s/^connection/#connection/" /etc/neutron/neutron.conf
sudo sed -i "s/^\[linux_bridge\]/\[linux_bridge\]\nphysical_interface_mappings = provider:enp0s3\n/" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i "s/^\[vxlan\]/\[vxlan\]\nenable_vxlan = True\nlocal_ip = 10.0.0.102\nl2_population = True\n/" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i "s/^\[securitygroup\]/\[securitygroup\]\nenable_security_group = True\nfirewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver\n/" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sh -c "cat <<'EOF'>>/etc/nova/nova.conf
[neutron]
url = http://controller:9696
auth_url = http://controller:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = password
EOF"
sudo service nova-compute restart
sudo service neutron-linuxbridge-agent restart

