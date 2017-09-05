default['storj']['share']['user'] = 'storj'
default['storj']['share']['group'] = 'storj'
default['storj']['share']['home'] = node['storj']['home']
default['storj']['share']['app_dir'] = "#{node['storj']['share']['home']}/share"
default['storj']['share']['log_dir'] = '/var/log/storj'
default['storj']['share']['log_file'] = 'share.log'
default['storj']['share']['repo'] = 'https://github.com/Storj/storjshare-daemon.git'
default['storj']['share']['node_env'] = 'production'
default['storj']['share']['revision'] = 'v4.0.1'
default['storj']['share']['config_dir'] = '/etc/storj'
default['storj']['share']['config_file_name'] = 'share.json'
default['storj']['share']['data_dir'] = 'data'
default['storj']['share']['key_file'] = 'share.key'
default['storj']['share']['migration_key_path'] = '/opt/storj/data/id_ecdsa'
default['storj']['share']['migration_data_path'] = '/opt/storj/.storjshare'

default['storj']['share']['config']['maxOfferConcurrency'] = 3
# Update the paymentAddress here otherwise you will not receive your payments
default['storj']['share']['config']['paymentAddress'] = '0x5ef2c8531b8abaaf6acd47a33e69cb223083d538'
default['storj']['share']['config']['bridges'] = [
  { "url" => "https://api.storj.io",
    "extendedKey" => "xpub6AHweYHAxk1EhJSBctQD1nLWPog6Sy2eTpKQLExR1hfzTyyZQWvU4EYNXv1NJN7GpLYXnDLt4PzN874g6zSjAQdFCHZN7U7nbYKYVDUzD42"
  }
]
default['storj']['share']['config']['seedList'] = [ ]
default['storj']['share']['config']['rpcAddress'] = '127.0.0.1'
default['storj']['share']['config']['rpcPort'] = 4000
default['storj']['share']['config']['doNotTraverseNat'] = false
default['storj']['share']['config']['maxTunnels'] = 3
default['storj']['share']['config']['maxConnections'] = 150
default['storj']['share']['config']['tunnelGatewayRange']['min'] = 4001
default['storj']['share']['config']['tunnelGatewayRange']['max'] = 4003
default['storj']['share']['config']['joinRetry']['times'] = 3000
default['storj']['share']['config']['joinRetry']['interval'] = 5000
default['storj']['share']['config']['offerBackoffLimit'] = 4
default['storj']['share']['config']['loggerVerbosity'] = 3
default['storj']['share']['config']['storagePath'] = File.join(node['storj']['share']['home'], node['storj']['share']['data_dir'])
default['storj']['share']['config']['storageAllocation'] = '10GB'
default['storj']['share']['config']['enableTelemetryReporting'] = true

default['storj']['share']['storj_bridge'] = 'https://api.storj.io'
default['storj']['share']['script_dir'] = '/usr/local/bin'
