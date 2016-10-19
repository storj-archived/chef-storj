# Should include LetsEncrypt here

# Find all of the rabbit nodes in this environment to build a cluster
rabbitmq_servers = {};
search(:node, 'recipes:storj\:\:bridge_queue AND chef_environment:production',
       :filter_result => { 'name' => [ 'name' ],
                           'ip' => [ 'ipaddress' ]
                         }
).each do |result|
  rabbitmq_servers[result['name']] = result['ip']
end

node.default['storj']['rabbitmq']['servers'] = rabbitmq_servers

include_recipe 'rabbitmq'

rabbitmq_plugin "rabbitmq_management" do
  action :enable
end
