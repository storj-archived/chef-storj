require 'securerandom'

include_recipe 'nvm'

nvm_install 'v6.9.1' do
  user_install true
  user node['storj']['share']['user']
  user_home node['storj']['share']['home']
  from_source false
  alias_as_default true
  action :create
end

# Create directories needed
directory node['storj']['share']['log_dir'] do
  owner node['storj']['share']['user']
  group node['storj']['share']['group']
  action :create
end

directory File.join(node['storj']['share']['home'], node['storj']['share']['data_dir']) do
  owner node['storj']['share']['user']
  group node['storj']['share']['group']
  action :create
end

# Check out correct version of StorjShare from Git
git node['storj']['share']['app_dir'] do
  repository node['storj']['share']['repo']
  revision node['storj']['share']['revision']
  user node['storj']['share']['user']
  group node['storj']['share']['group']
  environment Hash['HOME' => node['storj']['share']['home']]
  action :sync
  notifies :run, 'bash[install_share]', :immediately
end

generate_key_script_path = File.join(node['storj']['share']['script_dir'], 'generate_storjshare_key.js')

cookbook_file generate_key_script_path do
  action :create
end

if node['storj']['share']['password'].nil? && !File.exists?(File.join(node['storj']['share']['data_path'], 'id_ecdsa'))
  node.set['storj']['share']['password'] = SecureRandom.hex
end

template '/etc/init/share.conf' do
  variables ({
    :user => node['storj']['share']['user'],
    :group => node['storj']['share']['group'],
    :storj_network => node['storj']['share']['network_name'],
    :storj_bridge => node['storj']['share']['storj_bridge'],
    :app_dir => node['storj']['share']['app_dir'],
    :log_path => File.join(node['storj']['share']['log_dir'], node['storj']['share']['log_file']),
    :node_env => node['storj']['share']['node_env'],
    :node_index => node['storj']['share']['node_index'],
    :share_pw => node['storj']['share']['password'],
    :home => node['storj']['share']['home']
  })
  notifies :restart, 'service[share]'
  action :create
end

# Create the service for StorjShare
service 'share' do
  action :nothing
end

bash 'generate_key' do
  cwd "#{node['storj']['share']['app_dir']}"
  user node['storj']['share']['user']
  group node['storj']['share']['group']
  environment Hash['HOME' => node['storj']['share']['home']]
  code <<-EOH
    source #{File.join(node['storj']['share']['home'], '.nvm/nvm.sh')}
    PASSWORD=#{node['storj']['share']['password']} NODE_PATH=#{File.join(node['storj']['share']['app_dir'], 'node_modules')} node #{generate_key_script_path}
  EOH
  not_if { File.exists?(File.join(node['storj']['share']['data_path'], 'id_ecdsa')) }
  notifies :restart, 'service[share]'
  action :run
end

if node['cloud_v2']
  public_ip_address = node['cloud_v2']['public_ipv4_addrs'][0]
else
  public_ip_address = node['ipaddress']
end

template File.join(node['storj']['share']['data_path'], 'config.json') do
  owner node['storj']['share']['user']
  group node['storj']['share']['group']
  variables ({
    :key_path => File.join(node['storj']['share']['home'], node['storj']['share']['data_dir'], node['storj']['share']['key_file']),
    :payment_address => node['storj']['share']['payment_address'],
    :loglevel => node['storj']['share']['loglevel'],
    :concurrency => node['storj']['share']['concurrency'],
    :storage_path => File.join(node['storj']['share']['home'], node['storj']['share']['data_dir']),
    :storage_size => node['storj']['share']['storage']['size'],
    :storage_unit => node['storj']['share']['storage']['unit'],
    :network_address => public_ip_address,
    :network_port => node['storj']['share']['network']['port'],
    :network_seeds => node['storj']['share']['network']['seeds'],
    :network_forward => node['storj']['share']['network']['forward'],
    :network_tunnels => node['storj']['share']['network']['tunnels'],
    :network_tunnelport => node['storj']['share']['network']['tunnelport'],
    :network_gateways_min => node['storj']['share']['network']['gateways']['min'],
    :network_gateways_max => node['storj']['share']['network']['gateways']['max'],
    :telemetry_service => node['storj']['share']['telemetry']['service'],
    :telemetry_enabled => node['storj']['share']['telemetry']['enabled']
  })
  action :create
end

# Install or Update StorjShare and restart on any changes
bash 'install_share' do
  cwd "#{node['storj']['share']['app_dir']}"
  user node['storj']['share']['user']
  group node['storj']['share']['group']
  environment Hash['HOME' => node['storj']['share']['home']]
  code <<-EOH
    source #{node['storj']['share']['home']}/.nvm/nvm.sh
    rm -rf ./node_modules
    npm install
  EOH
  notifies :restart, 'service[share]'
  action :nothing
end
