renters = node['storj']['renter']['instances']
migration_privatekey_path = node['storj']['renter']['config']['opts']['migrationPrivateKey']
network_private_extendedkey_path = node['storj']['renter']['config']['opts']['networkPrivateExtendedKey']

renters.each do |name, renter|
  instance_name = 'renter-' + name
  renter_config_file = File.join(node['storj']['complex']['config-dir'], instance_name + '.json')

  if renter['migrationPrivateKey'] && migration_privatekey_path then
    file migration_privatekey_path do
      content renter['migrationPrivateKeyString']
      mode '0600'
      owner node['storj']['complex']['user']
      group node['storj']['complex']['group']
    end
  end

  if renter['networkPrivateExtendedKey'] && network_private_extendedkey_path then
    file network_private_extendedkey_path do
      content renter['networkPrivateExtendedKeyString']
      mode '0600'
      owner node['storj']['complex']['user']
      group node['storj']['complex']['group']
    end
  end

  template "/etc/init/#{instance_name}.conf" do
    source 'complex.conf.erb'
    variables ({
      :name => instance_name,
      :user => node['storj']['complex']['user'],
      :group => node['storj']['complex']['group'],
      :app_dir => node['storj']['complex']['app-dir'],
      :node_env => node['storj']['complex']['node-env'],
      :home => node['storj']['complex']['home'],
      :log_level => node['storj']['renter']['log-level'],
      :log_dir => node['storj']['renter']['log-dir'],
      :storj_network => node['storj']['bridge']['storj-network'],
      :config_file => File.join(node['storj']['complex']['config-dir'], instance_name + '.json')
    })
    action :create
  end

  config_defaults = node['storj']['renter']['config'].to_hash
  instance_config = renter['config'].to_hash

  def deep_merge(hash1, hash2)
    target = hash1.dup
    hash2.keys.each do |key|
      if hash1[key].is_a? Hash and hash2[key].is_a? Hash
        target[key] = deep_merge(target[key], hash2[key])
        next
      end

      target[key] = hash2[key]
    end

    target
  end

  merged_config = deep_merge(config_defaults, instance_config)

  template renter_config_file do
    source 'complex-config.erb'
    variables({
      :config => merged_config
    })
    action :create
  end

  service instance_name do
    action :nothing
    subscribes :restart, 'bash[install_complex]'
    subscribes :restart, "template[#{renter_config_file}]"
  end
end
