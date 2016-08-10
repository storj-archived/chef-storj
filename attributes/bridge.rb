default['storj']['bridge']['repo'] = 'https://github.com/Storj/bridge.git'
default['storj']['bridge']['revision'] = 'v0.7.3'
default['storj']['bridge']['version'] = 'v0.7.3'
default['storj']['bridge']['home'] = node['storj']['home']
default['storj']['bridge']['config-dir'] = '.storj-bridge'
default['storj']['bridge']['node-env'] = 'production'
default['storj']['bridge']['app-dir'] = "#{node['storj']['bridge']['home']}/bridge"
default['storj']['bridge']['user'] = 'storj'
default['storj']['bridge']['group'] = 'storj'
default['storj']['bridge']['log-dir'] = '/var/log/storj'
# This is overrideen per environment
default['storj']['bridge']['url'] = 'api.storj.io'

# These are the defaults for creating a Bridge API node
default['storj']['bridge']['server-host'] = node['storj']['bridge']['url']
default['storj']['bridge']['server-port'] = 8080
default['storj']['bridge']['server-timeout'] = 120000
default['storj']['bridge']['server-ssl-cert'] = true
default['storj']['bridge']['messaging']['url'] = 'amqp://localhost'
default['storj']['bridge']['messaging']['queues']['renterpool'] = {
  'name' => 'storj.work.renterpool',
  'options' => {
    'exclusive' => false,
    'durable' => true,
    'arguments' => {
      'messageTtl' => 120000
    }
  }
}
default['storj']['bridge']['messaging']['queues']['callback'] = {
  'name' => '',
  'options' => {
    'exclusive' => true,
    'durable' => false
  }
}
default['storj']['bridge']['messaging']['exchanges']['events'] = {
  'name' => 'storj.events',
  'type' => 'topic',
  'options' => {
    'durable' => true
  }
}
default['storj']['bridge']['storage']['db1'] = {
  "name" => "bridge",
  "host" => "localhost",
  "port" => 27017,
  "ssl" => false,
  "user" => nil,
  "pass" => nil,
  "mongos" => {
    "checkServerIdentity" => false,
    "ssl" => false,
    "sslValidate" => false
  }
}
default['storj']['bridge']['network']['minions']['minion1'] = {
  "bridge" => false,
  "address" => "127.0.0.1",
  "port" => 8443,
  "tunport" => 8444,
  "datadir" => File.join(node['storj']['bridge']['home'], node['storj']['bridge']['config-dir'], 'data'),
  "tunnels" => 32,
  "gateways" => {
    "min" => 8500,
    "max" => 8532
  },
  "privkey" => nil
}
default['storj']['bridge']['mailer']['host'] = 'localhost'
default['storj']['bridge']['mailer']['port'] = 465
default['storj']['bridge']['mailer']['auth']['user'] = nil
default['storj']['bridge']['mailer']['auth']['pass'] = nil
default['storj']['bridge']['mailer']['secure'] = true
default['storj']['bridge']['mailer']['from'] = 'mailer@storj.io'

