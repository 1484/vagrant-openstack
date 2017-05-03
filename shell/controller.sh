#!/bin/sh
sudo cp /vagrant/settings/hosts /etc/hosts
sudo add-apt-repository cloud-archive:newton -y
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install python-openstackclient python-pymysql -y
sudo apt-get install chrony -y
sudo sed -i "s/pool 2.debian.pool.ntp.org offline iburst/pool ntp.nict.jp offline iburst/g" /etc/chrony/chrony.conf
sudo service chrony restart
sudo apt-get install mariadb-server python-pymysql -y
sudo cp /vagrant/settings/openstack.cnf /etc/mysql/mariadb.conf.d/openstack.cnf
sudo service mysql restart
sudo apt-get install rabbitmq-server -y
sudo rabbitmqctl add_user openstack password
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
cp /vagrant/settings/admin-openrc  ~/admin-openrc
cp /vagrant/settings/demo-openrc ~/demo-openrc
sudo apt-get install memcached python-memcache -y
sudo sed -i "s/^-l 127.0.0.1/-l 10.0.0.101/" /etc/memcached.conf
sudo service memcached restart
sudo mysql -u root -ppassword << EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
IDENTIFIED BY 'password';
EOF
sudo apt-get install keystone -y
sudo sed -i "s/^connection = sqlite:\/\/\/\/var\/lib\/keystone\/keystone.db/connection = mysql+pymysql:\/\/keystone:password@controller\/keystone/" /etc/keystone/keystone.conf
sudo sed -i "s/^\[token\]/\[token\]\nprovider = fernet/" /etc/keystone/keystone.conf
sudo su -s /bin/sh -c "keystone-manage db_sync" keystone
sudo keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sudo keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
sudo keystone-manage bootstrap --bootstrap-password password \
  --bootstrap-admin-url http://controller:35357/v3/ \
  --bootstrap-internal-url http://controller:35357/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne
sudo sed -i "s/^# Global configuration/# Global configuration\nServerName controller/" /etc/apache2/apache2.conf
sudo service apache2 restart
sudo rm /var/lib/keystone/keystone.db
. /vagrant/settings/admin-openrc
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password password demo
openstack role create user
openstack role add --project demo --user demo user
sudo mysql -u root -ppassword << EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
 IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
IDENTIFIED BY 'password';
EOF
openstack user create --domain default --password password glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292
sudo apt-get install glance -y
sudo sed -i "s/^sqlite_db = \/var\/lib\/glance\/glance.sqlite/#sqlite_db = \/var\/lib\/glance\/glance.sqlite\nconnection = mysql+pymysql:\/\/glance:password@controller\/glance/" /etc/glance/glance-api.conf
sudo sed -i "s/^\[keystone_authtoken\]/\[keystone_authtoken\]\nauth_uri = http:\/\/controller:5000\nauth_url = http:\/\/controller:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nproject_name = service\nusername = glance\npassword = password\n/" /etc/glance/glance-api.conf
sudo sed -i "s/^\[paste_deploy\]/\[paste_deploy\]\nflavor = keystone\n/" /etc/glance/glance-api.conf

sudo sed -i "s/^sqlite_db = \/var\/lib\/glance\/glance.sqlite/#sqlite_db = \/var\/lib\/glance\/glance.sqlite\nconnection = mysql+pymysql:\/\/glance:password@controller\/glance/" /etc/glance/glance-registory.conf                   sudo sed -i "s/^\[keystone_authtoken\]/\[keystone_authtoken\]\nauth_uri = http:\/\/controller:5000\nauth_url = http:\/\/controller:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nproject_name = service\nusername = glance\npassword = password\n/" /etc/glance/glance-registry.conf
sudo sed -i "s/^\[paste_deploy\]/\[paste_deploy\]\nflavor = keystone\n/" /etc/glance/glance-registry.conf
sudo sed -i "s/^\[keystone_authtoken\]/\[keystone_authtoken\]\nauth_uri = http:\/\/controller:5000\nauth_url = http:\/\/controller:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nproject_name = service\nusername = glance\npassword = password\n/" /etc/glance/glance-registry.conf
sudo su -s /bin/sh -c "glance-manage db_sync" glance
sudo service glance-registry restart 
sudo service glance-api restart
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
openstack image create "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
sudo mysql -u root -ppassword << EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' \
IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' \
IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
IDENTIFIED BY 'password';
EOF
openstack user create --domain default --password password nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1/%\(tenant_id\)s
sudo apt-get install nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler -y
sudo sed -i "s/^\[DEFAULT\]/\[DEFAULT\]\nenabled_apis = osapi_compute,metadata\ntransport_url = rabbit:\/\/openstack:password@controller\nauth_strategy = keystone\nuse_neutron = True\nfirewall_driver = nova.virt.firewall.NoopFirewallDriver\nmy_ip = 10.0.0.101\n/" /etc/nova/nova.conf
sudo sed -i "s/^connection/#connection/g" /etc/nova/nova.conf
sudo sed -i "s/^\[api_database\]/\[api_database\]\nconnection = mysql+pymysql:\/\/nova:password@controller\/nova_api\n/" /etc/nova/nova.conf
sudo sed -i "s/^\[database\]/\[database\]\nconnection = mysql+pymysql:\/\/nova:password@controller\/nova\n/" /etc/nova/nova.conf
sudo sed -i "s/^lock_path=\/var\/lock\/nova/lock_path = \/var\/lib\/nova\/tmp/" /etc/nova/nova.conf
sudo sh -c "cat <<'EOF'>>/etc/nova/nova.conf
[vnc]
vncserver_listen = \$my_ip
vncserver_proxyclient_address = \$my_ip

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
EOF"
sudo su -s /bin/sh -c "nova-manage api_db sync" nova
sudo su -s /bin/sh -c "nova-manage db sync" nova
sudo service nova-api restart
sudo service nova-consoleauth restart
sudo service nova-scheduler restart
sudo service nova-conductor restart
sudo service nova-novncproxy restart
sudo rm /var/lib/nova/nova.sqlite

sudo mysql -u root -ppassword << EOF
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' \
  IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' \
  IDENTIFIED BY 'password';
EOF
openstack user create --domain default --password password neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696
sudo apt-get install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent -y
sudo sed -i "s/^core_plugin = ml2/core_plugin = ml2\nservice_plugins = router\nallow_overlapping_ips = True\nrpc_backend = rabbit\nauth_strategy = keystone\nnotify_nova_on_port_status_changes = True\nnotify_nova_on_port_data_changes = True\n/" /etc/neutron/neutron.conf
sudo sed -i "s/^\[oslo_messaging_rabbit\]/\[oslo_messaging_rabbit\]\nrabbit_host = controller\nrabbit_userid = openstack\nrabbit_password = password\n/" /etc/neutron/neutron.conf
sudo sed -i "s/^\[keystone_authtoken\]/\[keystone_authtoken\]\nauth_uri = http:\/\/controller:5000\nauth_url = http:\/\/controller:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nproject_name = service\nusername = neutron\npassword = password\n/" /etc/neutron/neutron.conf
sudo sed -i "s/^connection = sqlite:\/\/\/\/var\/lib\/neutron\/neutron.sqlite/connection = mysql+pymysql:\/\/neutron:password@controller\/neutron/" /etc/neutron/neutron.conf
sudo sed -i "s/^\[nova\]/\[nova\]\nauth_url = http:\/\/controller:35357\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nregion_name = RegionOne\nproject_name = service\nusername = nova\npassword = password\n/" /etc/neutron/neutron.conf
sudo sed -i "s/^\[ml2\]/\[ml2\]\ntype_drivers = flat,vlan,vxlan\ntenant_network_types = vxlan\nmechanism_drivers = linuxbridge,l2population\nextension_drivers = port_security\n/" /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i "s/^\[ml2_type_flat\]/\[ml2_type_flat\]\nflat_networks = provider\n/" /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i "s/^\[ml2_type_vxlan\]/\[ml2_type_vxlan\]\nvni_ranges = 1:1000\n/" /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i "s/^\[securitygroup\]/\[securitygroup\]\nenable_ipset = True\n/" /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i "s/^\[linux_bridge\]/\[linux_bridge\]\nphysical_interface_mappings = provider:enp0s3\n/" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i "s/^\[vxlan\]/\[vxlan\]\nenable_vxlan = True\nlocal_ip = 10.0.0.101\nl2_population = True\n/" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i "s/^\[securitygroup\]/\[securitygroup\]\nenable_security_group = True\nfirewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver\n/" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i "s/^\[DEFAULT\]/\[DEFAULT\]\ninterface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver\nexternal_network_bridge =\n/" /etc/neutron/l3_agent.ini
sudo sed -i "s/^\[DEFAULT\]/\[DEFAULT\]\ninterface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver\ndhcp_driver = neutron.agent.linux.dhcp.Dnsmasq\nenable_isolated_metadata = True\n/" /etc/neutron/dhcp_agent.ini
sudo sed -i "s/^\[DEFAULT\]/\[DEFAULT\]\nnova_metadata_ip = controller\nmetadata_proxy_shared_secret = METADATA_SECRET\n/" /etc/neutron/metadata_agent.ini
sudo sh -c "cat <<'EOF'>> /etc/nova/nova.conf

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
service_metadata_proxy = True
metadata_proxy_shared_secret = METADATA_SECRET
EOF"
sudo su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
sudo service nova-api restart
sudo service neutron-server restart
sudo service neutron-linuxbridge-agent restart
sudo service neutron-dhcp-agent restart
sudo service neutron-metadata-agent restart
sudo service neutron-l3-agent restart
sudo apt-get install openstack-dashboard -y
sudo sed -i "s/^WEBROOT = '\/'/WEBROOT = '\/horizon\/'/" /etc/openstack-dashboard/local_settings.py
sudo sh -c "echo SESSION_ENGINE = \'django.contrib.sessions.backends.cache\' >> /etc/openstack-dashboard/local_settings.py"
sudo sed -i "s/^OPENSTACK_HOST = \"127.0.0.1\"/OPENSTACK_HOST = \"controller\"/" /etc/openstack-dashboard/local_settings.py
sudo sed -i "s/^OPENSTACK_KEYSTONE_URL = \"http:\/\/%s:5000\/v2.0/OPENSTACK_KEYSTONE_URL = \"http:\/\/%s:5000\/v3/" /etc/openstack-dashboard/local_settings.py
sudo sed -i "s/^OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"_member_\"/OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"/" /etc/openstack-dashboard/local_settings.py
sudo sed -i "s/^TIME_ZONE = \"UTC\"/TIME_ZONE = \"Asia\/Tokyo\"/" /etc/openstack-dashboard/local_settings.py
sudo service apache2 restart

