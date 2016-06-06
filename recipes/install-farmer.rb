include_recipe 'nvm'

nvm_install 'v4.4.4' do
  user_install true
  user node['storj']['farmer']['user']
  user_home node['storj']['farmer']['home']
  from_source false
  alias_as_default true
  action :create
end

directory node['storj']['farmer']['log_dir'] do
  owner node['storj']['farmer']['user']
  group node['storj']['farmer']['group']
  action :create
end

directory File.join(node['storj']['farmer']['home'], node['storj']['farmer']['data_dir']) do
  owner node['storj']['farmer']['user']
  group node['storj']['farmer']['group']
  action :create
end

storj_protocol = node['storj']['farmer']['version']
if node['storj']['farmer']['protocol']
  storj_protocol += "-#{node['storj']['farmer']['protocol']}"
end

template '/etc/init/farmer.conf' do
  variables ({
    :user => node['storj']['farmer']['user'],
    :group => node['storj']['farmer']['group'],
    :storj_protocol => storj_protocol,
    :app_dir => node['storj']['farmer']['app_dir'],
    :log_path => File.join(node['storj']['farmer']['log_dir'], node['storj']['farmer']['log_file']),
    :node_env => node['storj']['farmer']['node_env'],
    :node_index => node['storj']['farmer']['node_index'],
    :farmer_pw => node['storj']['farmer']['password'],
    :home => node['storj']['farmer']['home']
  })
  action :create
end

if node['cloud_v2']
  public_ip_address = node['cloud_v2']['public_ipv4_addrs'][0]
else
  public_ip_address = node['ipaddress']
end

template File.join(node['storj']['farmer']['home'], node['storj']['farmer']['data_dir'], 'config.json') do
  owner node['storj']['farmer']['user']
  group node['storj']['farmer']['group']
  variables ({
    :key_path => File.join(node['storj']['farmer']['home'], node['storj']['farmer']['data_dir'], node['storj']['farmer']['key_file']),
    :payment_address => node['storj']['farmer']['payment_address'],
    :storage_path => File.join(node['storj']['farmer']['home'], node['storj']['farmer']['data_dir']),
    :storage_size => node['storj']['farmer']['storage']['size'],
    :storage_unit => node['storj']['farmer']['storage']['unit'],
    :network_address => public_ip_address,
    :network_port => node['storj']['farmer']['network']['port'],
    :network_seeds => node['storj']['farmer']['network']['seeds'],
    :network_forward => node['storj']['farmer']['network']['forward'],
    :network_tunnels => node['storj']['farmer']['network']['tunnels'],
    :network_tunnelport => node['storj']['farmer']['network']['tunnelport'],
    :network_gateways_min => node['storj']['farmer']['network']['gateways']['min'],
    :network_gateways_max => node['storj']['farmer']['network']['gateways']['max'],
    :telemetry_service => node['storj']['farmer']['telemetry']['service'],
    :telemetry_enabled => node['storj']['farmer']['telemetry']['enabled']
  })
  action :create
end

git node['storj']['farmer']['app_dir'] do
  repository node['storj']['farmer']['repo']
  revision node['storj']['farmer']['revision']
  user node['storj']['farmer']['user']
  group node['storj']['farmer']['group']
  action :sync
  notifies :run, 'bash[install_farmer]', :immediately
end

bash 'install_farmer' do
  cwd "#{node['storj']['farmer']['app_dir']}"
  user node['storj']['farmer']['user']
  group node['storj']['farmer']['group']
  environment Hash['HOME' => node['storj']['farmer']['home']]
  code <<-EOH
    source #{node['storj']['farmer']['home']}/.nvm/nvm.sh
    rm -rf ./node_modules
    npm install
  EOH
  notifies :restart, 'service[farmer]', :immediately
  action :nothing
end

service 'farmer' do
  action :nothing
end

