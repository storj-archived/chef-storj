# These attributes should be overrideen per environment
default['storj']['bridge']['repo'] = 'https://github.com/Storj/bridge.git'
default['storj']['bridge']['revision'] = 'v1.2.1'
default['storj']['bridge']['log-level'] = 2
default['storj']['bridge']['home'] = node['storj']['home']
default['storj']['bridge']['node-env'] = 'production'
default['storj']['bridge']['config']['application']['mirrors'] = 6
default['storj']['bridge']['app-dir'] = "#{node['storj']['bridge']['home']}/bridge"
default['storj']['bridge']['config-dir'] = '/etc/storj'
default['storj']['bridge']['user'] = 'storj'
default['storj']['bridge']['group'] = 'storj'
default['storj']['bridge']['log-dir'] = '/var/log/storj'
default['storj']['bridge']['url'] = 'api.storj.io'

# This should be generated or overridden
default['storj']['bridge']['config']['application']['privateKey'] = nil
default['storj']['bridge']['config']['application']['farmerTimeoutIgnore'] = '10m'

# Host and Port to bind to locally
default['storj']['bridge']['config']['server']['host'] = "0.0.0.0"
default['storj']['bridge']['config']['server']['port'] = 8080
default['storj']['bridge']['config']['server']['timeout'] = 120000
default['storj']['bridge']['config']['server']['ssl']['cert'] = true

# Host and Port through which the api service is publicly reachable
default['storj']['bridge']['config']['server']['public']['host'] = 'api.storj.io'
default['storj']['bridge']['config']['server']['public']['port'] = 443
default['storj']['bridge']['config']['storage'] = [
  {
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
]
default['storj']['bridge']['config']['complex']['rpcUrl'] = 'http://localhost:8081'
default['storj']['bridge']['config']['complex']['rpcUser'] = 'storj_user'
default['storj']['bridge']['config']['complex']['rpcPassword'] = 'thisshouldbeareallyawesomeandhardtoguesspassword'

default['storj']['bridge']['config']['messaging']['url'] = 'amqp://localhost'

default['storj']['bridge']['config']['mailer']['host'] = 'localhost'
default['storj']['bridge']['config']['mailer']['port'] = 465
default['storj']['bridge']['config']['mailer']['auth']['user'] = nil
default['storj']['bridge']['config']['mailer']['auth']['pass'] = nil
default['storj']['bridge']['config']['mailer']['secure'] = true
default['storj']['bridge']['config']['mailer']['from'] = 'mailer@storj.io'

# Example bridge instance
# To create a bridge instance (without using the defaults) the minimum required is to
# set atleast one attribute in the context of ['bridge']['instances']. The easiest way
# to do this is to override the port, even if it is the same as the default port.
# node.set['storj']['bridge']['instances']['1']['config']['server']['port'] = 8001
