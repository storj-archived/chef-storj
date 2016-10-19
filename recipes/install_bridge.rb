include_recipe 'storj::install_deps'

directory node['storj']['bridge']['config-dir'] do
  recursive true
  owner node['storj']['bridge']['user']
  group node['storj']['bridge']['group']
  action :create
end

directory File.join(node['storj']['bridge']['config-dir'], 'config') do
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
  action :nothing
end
