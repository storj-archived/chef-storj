landlord_config = node['storj']['landlord']['config']
landlord_config_file = File.join(node['storj']['complex']['config-dir'], node['storj']['landlord']['config-name'])

template '/etc/init/landlord.conf' do
  source 'complex.conf.erb'
  variables ({
    :name => 'landlord',
    :user => node['storj']['complex']['user'],
    :group => node['storj']['complex']['group'],
    :app_dir => node['storj']['complex']['app-dir'],
    :node_env => node['storj']['complex']['node-env'],
    :home => node['storj']['complex']['home'],
    :log_dir => node['storj']['landlord']['log-dir'],
    :log_level => node['storj']['landlord']['config']['opts']['logLevel'],
    :storj_network => node['storj']['bridge']['storj-network'],
    :config_file => landlord_config_file
  })
  action :create
end

template File.join(landlord_config_file) do
  source 'complex-config.erb'
  variables({
    :config => landlord_config,
  })
  action :create
end

service 'landlord' do
  action :nothing
  subscribes :restart, "bash[install_complex]"
  subscribes :restart, "template[#{landlord_config_file}]"
end
