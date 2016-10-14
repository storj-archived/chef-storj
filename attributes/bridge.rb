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
default['storj']['bridge']['server']['host'] = node['storj']['bridge']['url']
default['storj']['bridge']['server']['port'] = 8080
default['storj']['bridge']['server']['timeout'] = 120000
default['storj']['bridge']['server']['ssl-cert'] = true
default['storj']['bridge']['server']['public']['host'] = '127.0.0.1'
default['storj']['bridge']['server']['public']['port'] = 8080
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
default['storj']['bridge']['complex']['rpcUrl'] = 'http://localhost:8081'
default['storj']['bridge']['complex']['rpcUser'] = 'storj_user'
default['storj']['bridge']['complex']['rpcPassword'] = 'thisshouldbeareallyawesomeandhardtoguesspassword'
default['storj']['bridge']['mailer']['host'] = 'localhost'
default['storj']['bridge']['mailer']['port'] = 465
default['storj']['bridge']['mailer']['auth']['user'] = nil
default['storj']['bridge']['mailer']['auth']['pass'] = nil
default['storj']['bridge']['mailer']['secure'] = true
default['storj']['bridge']['mailer']['from'] = 'mailer@storj.io'
