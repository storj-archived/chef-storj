bridges = node['storj']['bridge']['instances']

bridges.each do |name, bridge|
  instance_name = 'bridge-' + name
  node_env = "#{node['storj']['bridge']['node-env']}-#{name}"
  bridge_config_file = File.join(node['storj']['bridge']['config-dir'], 'config', node_env)

  template "/etc/init/#{instance_name}.conf" do
    source "bridge.conf.erb"
    variables ({
      :name => instance_name,
      :user => node['storj']['bridge']['user'],
      :group => node['storj']['bridge']['group'],
      :app_dir => node['storj']['bridge']['app-dir'],
      :node_env => node_env,
      :storj_network => node['storj']['bridge']['storj-network'],
      :log_level => node['storj']['bridge']['log-level'],
      :home => node['storj']['bridge']['home']
    })
    action :create
  end

  config_defaults = node['storj']['bridge']['config'].to_hash
  instance_config = bridge['config'].to_hash

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

  template bridge_config_file do
    source 'bridge-config.erb'
    variables({
      :config => merged_config
    })
    action :create
    notifies :restart, "service[#{instance_name}]"
  end

  service instance_name do
    action :nothing
    subscribes :restart, "bash[install_bridge]"
    subscribes :restart, "template[#{bridge_config_file}]"
  end
end
