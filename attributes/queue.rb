default['rabbitmq']['default_user'] = 'storjuser'
default['rabbitmq']['default_pass'] = 'storjguest'
override['rabbitmq']['version'] = '3.6.5'
override['rabbitmq']['deb_package'] = "rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb"
override['rabbitmq']['deb_package_url'] = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}/"

default['rabbitmq']['enabled_plugins'] = [
  'rabbitmq_management'
]

# Bind to local address
default['rbabtimq']['kernel']['inet_dist_use_interface'] = node['ipaddress']
