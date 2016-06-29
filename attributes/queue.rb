default['rabbitmq']['default_user'] = 'storjuser'
default['rabbitmq']['default_pass'] = 'storjguest'
default['rabbitmq']['version'] = '3.6.2'
default['rabbitmq']['enabled_plugins'] = [
  'rabbitmq_management'
]

# Bind to local address
default['rbabtimq']['kernel']['inet_dist_use_interface'] = node['ipaddress']
