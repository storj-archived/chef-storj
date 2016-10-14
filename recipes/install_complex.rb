include_recipe 'storj::install_deps'

directory node['storj']['complex']['config-dir'] do
  recursive true
  owner node['storj']['complex']['user']
  group node['storj']['complex']['group']
  action :create
end

directory File.join(node['storj']['complex']['config-dir'], 'keys') do
  recursive true
  owner node['storj']['complex']['user']
  group node['storj']['complex']['group']
  action :create
end

directory node['storj']['landlord']['log-dir'] do
  owner node['storj']['complex']['user']
  group node['storj']['complex']['group']
  action :create
end

git node['storj']['complex']['app-dir'] do
  repository node['storj']['complex']['repo']
  revision node['storj']['complex']['revision']
  user node['storj']['complex']['user']
  group node['storj']['complex']['group']
  action :sync
  notifies :run, 'bash[install_complex]', :immediately
end

bash 'install_complex' do
  cwd "#{node['storj']['complex']['app-dir']}"
  user node['storj']['complex']['user']
  group node['storj']['complex']['group']
  environment Hash['HOME' => node['storj']['complex']['home']]
  code <<-EOH
    source #{node['storj']['complex']['home']}/.nvm/nvm.sh
    rm -rf ./node_modules
    npm install
  EOH
  action :nothing
end
