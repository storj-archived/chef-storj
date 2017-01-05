landlord_config = node['storj']['landlord']['config']
landlord_config_path = File.join(node['storj']['complex']['config-dir'], node['storj']['landlord']['config-name'])
init_style = node['storj']['landlord']['init_style'] || node['storj']['init_style']
log_path = File.join(node['storj']['landlord']['log-dir'], 'landlord.log')

if init_style == 'systemd'
  template '/etc/systemd/system/landlord.service' do
    source 'complex.systemd.erb'
    variables ({
      :name => 'landlord',
      :user => node['storj']['complex']['user'],
      :group => node['storj']['complex']['group'],
      :app_dir => node['storj']['complex']['app-dir'],
      :node_env => node['storj']['complex']['node-env'],
      :home => node['storj']['complex']['home'],
      :log_path => log_path,
      :log_level => node['storj']['landlord']['config']['opts']['logLevel'],
      :storj_network => node['storj']['bridge']['storj-network'],
      :config_path => landlord_config_path
    })
    action :create
  end
else
  template '/etc/init/landlord.conf' do
    source 'complex.conf.erb'
    variables ({
      :name => 'landlord',
      :user => node['storj']['complex']['user'],
      :group => node['storj']['complex']['group'],
      :app_dir => node['storj']['complex']['app-dir'],
      :node_env => node['storj']['complex']['node-env'],
      :home => node['storj']['complex']['home'],
      :log_path => log_path,
      :log_level => node['storj']['landlord']['config']['opts']['logLevel'],
      :storj_network => node['storj']['bridge']['storj-network'],
      :config_path => landlord_config_path
    })
    action :create
  end
end

template File.join(landlord_config_path) do
  source 'complex-config.erb'
  variables({
    :config => landlord_config,
  })
  action :create
end

service 'landlord' do
  action :nothing
  subscribes :restart, "bash[install_complex]"
  subscribes :restart, "template[#{landlord_config_path}]"
end
