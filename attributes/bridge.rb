default['storj']['bridge']['repo'] = 'https://github.com/Storj/bridge.git'
default['storj']['bridge']['revision'] = 'v0.7.3'
default['storj']['bridge']['version'] = 'v0.7.3'
default['storj']['bridge']['home'] = node['storj']['home']
default['storj']['bridge']['node-env'] = 'production'
default['storj']['bridge']['config-dir'] = File.join(node['storj']['bridge']['home'], '.storj-bridge')
default['storj']['bridge']['app-dir'] = "#{node['storj']['bridge']['home']}/bridge"
default['storj']['bridge']['user'] = 'storj'
default['storj']['bridge']['group'] = 'storj'
default['storj']['bridge']['log-dir'] = '/var/log/storj'
default['storj']['bridge']['log-level'] = 2
# This is overrideen per environment
default['storj']['bridge']['url'] = 'api.storj.io'

# These are the defaults for creating a Bridge API node
default['storj']['bridge']['config']['application']['mirrors'] = 6

# This should be generated or overridden
default['storj']['bridge']['config']['application']['privateKey'] = nil
# Host and Port to bind to locally
default['storj']['bridge']['config']['server']['host'] = "0.0.0.0"
default['storj']['bridge']['config']['server']['port'] = 8080
default['storj']['bridge']['config']['server']['timeout'] = 120000
default['storj']['bridge']['config']['server']['ssl']['cert'] = true
# Host and Port through which the api service is publicly reachable
default['storj']['bridge']['config']['server']['public']['host'] = 'api.storj.io'
default['storj']['bridge']['config']['server']['public']['port'] = 443
default['storj']['bridge']['config']['storage'] = [
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
]
default['storj']['bridge']['config']['complex']['rpcUrl'] = 'http://localhost:8081'
default['storj']['bridge']['config']['complex']['rpcUser'] = 'storj_user'
default['storj']['bridge']['config']['complex']['rpcPassword'] = 'thisshouldbeareallyawesomeandhardtoguesspassword'
default['storj']['bridge']['config']['mailer']['host'] = 'localhost'
default['storj']['bridge']['config']['mailer']['port'] = 465
default['storj']['bridge']['config']['mailer']['auth']['user'] = nil
default['storj']['bridge']['config']['mailer']['auth']['pass'] = nil
default['storj']['bridge']['config']['mailer']['secure'] = true
default['storj']['bridge']['config']['mailer']['from'] = 'mailer@storj.io'
