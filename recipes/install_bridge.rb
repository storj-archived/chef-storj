include_recipe 'storj::install_deps'

directory File.join(node['storj']['bridge']['config-dir']) do
  recursive true
  owner node['storj']['bridge']['user']
  group node['storj']['bridge']['group']
  action :create
end

directory node['storj']['bridge']['log-dir'] do
  owner node['storj']['bridge']['user']
  group node['storj']['bridge']['group']
  action :create
end

template '/etc/init/bridge.conf' do
  variables ({
    :user => node['storj']['bridge']['user'],
    :group => node['storj']['bridge']['group'],
    :app_dir => node['storj']['bridge']['app-dir'],
    :node_env => node['storj']['bridge']['node-env'],
    :storj_network => node['storj']['bridge']['storj-network'],
    :log_level => node['storj']['bridge']['log-level'],
    :home => node['storj']['bridge']['home']
  })
  action :create
end

template File.join(node['storj']['bridge']['config-dir'], 'config', node['storj']['bridge']['node-env']) do
  source 'bridge-config.erb'
  variables({
    :application_mirrors => node['storj']['bridge']['application']['mirrors'],
    :application_privatekey => node['storj']['bridge']['application']['privatekey'],
    :server_host => node['storj']['bridge']['server']['host'],
    :server_port => node['storj']['bridge']['server']['port'],
    :server_ssl_cert => node['storj']['bridge']['server']['ssl-cert'],
    :server_timeout => node['storj']['bridge']['server']['timeout'],
    :server_public_host => node['storj']['bridge']['server']['public']['host'],
    :server_public_port => node['storj']['bridge']['server']['public']['port'],
    :storage => node['storj']['bridge']['storage'],
    :complex_rpcurl => node['storj']['bridge']['complex']['rpcUrl'],
    :complex_rpcuser => node['storj']['bridge']['complex']['rpcUser'],
    :complex_rpcpassword => node['storj']['bridge']['complex']['rpcPassword'],
    :mailer_host => node['storj']['bridge']['mailer']['host'],
    :mailer_port => node['storj']['bridge']['mailer']['port'],
    :mailer_auth_user => node['storj']['bridge']['mailer']['auth']['user'],
    :mailer_auth_pass => node['storj']['bridge']['mailer']['auth']['pass'],
    :mailer_secure => node['storj']['bridge']['mailer']['secure'],
    :mailer_from => node['storj']['bridge']['mailer']['from']
  })
  action :create
  notifies :restart, 'service[bridge]'
end

git node['storj']['bridge']['app-dir'] do
  repository node['storj']['bridge']['repo']
  revision node['storj']['bridge']['revision']
  user node['storj']['bridge']['user']
  group node['storj']['bridge']['group']
  action :sync
  notifies :run, 'bash[install_bridge]', :immediately
end

bash 'install_bridge' do
  cwd "#{node['storj']['bridge']['app-dir']}"
  user node['storj']['bridge']['user']
  group node['storj']['bridge']['group']
  environment Hash['HOME' => node['storj']['bridge']['home']]
  code <<-EOH
    source #{node['storj']['bridge']['home']}/.nvm/nvm.sh
    rm -rf ./node_modules
    npm install
  EOH
  notifies :restart, 'service[bridge]', :immediately
  action :nothing
end

service 'bridge' do
  action :nothing
end
