require 'securerandom'

include_recipe 'nvm'

share_data_path = node['storj']['share']['config']['storagePath']
share_key_path = File.join(share_data_path, node['storj']['share']['key_file'])
migration_share_data_path = node['storj']['share']['migration_data_path']
migration_share_key_path = node['storj']['share']['migration_key_path']
migration_share_password = node['storj']['share']['password']
generate_key_script_path = File.join(node['storj']['share']['script_dir'], 'generate_storjshare_key.js')
migrate_key_script_path = File.join(node['storj']['share']['script_dir'], 'migrate_storjshare_key.js')
config_path = File.join(node['storj']['share']['config_dir'], node['storj']['share']['config_file_name'])


nvm_install node['storj']['nodejs']['version'] do
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

# Create config directory
directory node['storj']['share']['config_dir'] do
  owner node['storj']['share']['user']
  group node['storj']['share']['group']
  action :create
end

cookbook_file generate_key_script_path do
  action :create
end

cookbook_file migrate_key_script_path do
  action :create
end

# If the node['storj']['share']['data_path'] attr exists on this node, rename the directory to the
# new name. Moving away from dotfile folder for the storage path as to not obscure where things
# are kept

ruby_block "Migrate Share Data" do
  block do
    ::File.rename(migration_share_data_path, share_data_path)
  end

  only_if { migration_share_data_path && share_data_path && File.exists?(migration_share_data_path) && !File.exists?(share_data_path) }
end

bash 'migrate key' do
  cwd "#{share_data_path}"
  user node['storj']['share']['user']
  group node['storj']['share']['user']
  environment Hash['HOME' => node['storj']['share']['home']]
  code <<-EOH
    source #{File.join(node['storj']['share']['home'], '.nvm/nvm.sh')}
    KEY_PATH=#{share_key_path} MIGRATION_KEY_PATH=#{migration_share_key_path} PASSWORD=#{migration_share_password} NODE_PATH=#{File.join(node['storj']['share']['app_dir'], 'node_modules')} node #{migrate_key_script_path}
  EOH
  only_if { migration_share_data_path && share_data_path && File.exists?(migration_share_key_path) && !File.exists?(share_key_path) }
end

# Create directory for our shared drive storage
directory File.join(node['storj']['share']['config']['storagePath']) do
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

# This is unused now that we are not encrypting the private key
# Need to catch the case where the node attribute doesnt exist but the keyfile exists
#if node['storj']['share']['password'].nil? && !File.exists?(File.join(node['storj']['share']['config']['storagePath'], 'id_ecdsa'))
#  node.set['storj']['share']['password'] = SecureRandom.hex
#end

init_style = node['storj']['share']['init_style'] || node['storj']['init_style']
log_path = File.join(node['storj']['share']['log_dir'], node['storj']['share']['log_file'])

if init_style == 'systemd'
  template '/etc/systemd/system/share.service' do
    source 'share.systemd.erb'
    variables ({
      :app_dir => node['storj']['share']['app_dir'],
      :config_path => config_path,
      :group => node['storj']['share']['group'],
      :home => node['storj']['share']['home'],
      :log_path => log_path,
      :node_env => node['storj']['share']['node_env'],
      :storj_network => node['storj']['share']['network_name'],
      :user => node['storj']['share']['user']
    })
    notifies :restart, 'service[share]'
    action :create
  end
else
  template '/etc/init/share.conf' do
    variables ({
      :app_dir => node['storj']['share']['app_dir'],
      :config_path => config_path,
      :group => node['storj']['share']['group'],
      :home => node['storj']['share']['home'],
      :log_path => log_path,
      :node_env => node['storj']['share']['node_env'],
      :storj_network => node['storj']['share']['network_name'],
      :user => node['storj']['share']['user']
    })
    notifies :restart, 'service[share]'
    action :create
  end
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
    export KEY_PATH=#{File.join(node['storj']['share']['config']['storagePath'], 'priv_key')}
    PASSWORD=#{node['storj']['share']['password']} NODE_PATH=#{File.join(node['storj']['share']['app_dir'], 'node_modules')} node #{generate_key_script_path}
  EOH
  not_if { File.exists?(File.join(node['storj']['share']['config']['storagePath'], 'priv_key')) }
  notifies :restart, 'service[share]'
  action :run
end

if File.exist?(share_key_path)
  node.set['storj']['share']['config']['networkPrivateKey'] = ::File.read(share_key_path).chomp
end

if node['cloud_v2']
  public_ip_address = node['cloud_v2']['public_ipv4_addrs'][0]
else
  public_ip_address = node['ipaddress']
end

logger_output_file = File.join(node['storj']['share']['log_dir'], node['storj']['share']['log_file'])

node.set['storj']['share']['config']['rpcAddress'] = public_ip_address
node.set['storj']['share']['config']['loggerOutputFile'] = logger_output_file

farmer_config = node['storj']['share']['config'].to_hash

template File.join(config_path) do
  source 'share.json.erb'
  owner node['storj']['share']['user']
  group node['storj']['share']['group']
  variables ({
    :config => farmer_config
  })
  action :create
  notifies :restart, 'service[share]'
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
