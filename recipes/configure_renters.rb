require 'digest/sha1'

migration_privatekey_path = node['storj']['renter']['config']['opts']['migrationPrivateKey']
network_private_extendedkey_path = node['storj']['renter']['config']['opts']['networkPrivateExtendedKey']

mac_address = node['macaddress']
index_base = Digest::SHA1.hexdigest(mac_address).to_s[0,6].hex

instance_count = node['storj']['renter']['instance_count']
beginPort = node['storj']['renter']['begin_port']
tunnelGatewayMin = node['storj']['renter']['config']['opts']['networkOpts']['tunnelGatewayRange']['min']
tunnelGatewayMax = node['storj']['renter']['config']['opts']['networkOpts']['tunnelGatewayRange']['max']
maxTunnels = node['storj']['renter']['config']['opts']['networkOpts']['maxTunnels']
bridgeUri = node['storj']['renter']['config']['opts']['networkOpts']['bridgeUri']
maxConnections = node['storj']['renter']['config']['opts']['networkOpts']['maxConnections']
migrationPrivateKeyString = node['storj']['renter']['migrationPrivateKeyString']
networkPrivateExtendedKeyString = node['storj']['renter']['networkPrivateExtendedKeyString']

(1..instance_count).each do |index|
  # Renter instances
  node.set['storj']['renter']['instances']["#{index}"] = {
    "migrationPrivateKey" => migration_privatekey_path,
    "networkPrivateExtendedKey" => network_private_extendedkey_path,
    "config" => {
      "opts" => { "networkIndex" => index_base + index,
        "networkOpts" => {
          "rpcPort" => beginPort+=1,
          "tunnelServerPort" => beginPort+=1,
          "tunnelGatewayRange" => {
            "min" => tunnelGatewayMin,
            "max" => tunnelGatewayMax
          },
          "maxTunnels" => maxTunnels,
          "bridgeUri" => bridgeUri,
          "maxConnections" => maxConnections
        },
      }
    }
  }
end

renters = node['storj']['renter']['instances']

renters.each do |name, renter|
  instance_name = 'renter-' + name
  renter_config_file = File.join(node['storj']['complex']['config-dir'], instance_name + '.json')

  if migrationPrivateKeyString && migration_privatekey_path then
    file migration_privatekey_path do
      content migrationPrivateKeyString
      mode '0600'
      owner node['storj']['complex']['user']
      group node['storj']['complex']['group']
    end
  end

  if networkPrivateExtendedKeyString && network_private_extendedkey_path then
    file network_private_extendedkey_path do
      content networkPrivateExtendedKeyString
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
