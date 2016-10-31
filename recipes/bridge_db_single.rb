include_recipe "storj"

# Generating SSL certs and keys...
# openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-server-cert.crt -keyout mongodb-server-cert.key
# openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-client-cert.crt -keyout mongodb-client-cert.key
# cat mongodb-server-cert.key mongodb-server-cert.crt > mongodb-server.pem
# cat mongodb-client-cert.key mongodb-client-cert.crt > mongodb-client.pem
# Copy server and client pem into /etc/mongodb/keys
# We use server pem on the mongod instance for key and client as the ca, then reverse for
# any clients including mongos and config servers
#
# Must add all hosts to the hosts file
#
# Connect to the mongod node with...
# mongo bridge-db-1:27017/test --ssl --sslAllowInvalidCertificates --sslCAFile /etc/mongodb/keys/mongodb-server.pem --sslPEMKeyFile /etc/mongodb/keys/mongodb-client.pem
#
# Use 27020 (mongos) to create user on bridge db
# db.createUser({ user: "storj", pwd: "pw_goes_here", roles: [ { role: "readWrite", "db": "bridge" } ] })
#
# Update hostname on initial host in replica set
# mongod> cfg = rs.conf()
# mongod> cfg.members[0].host = "bridge-db-1:27017"
# rs.reconfig(cfg)
#
# Add the mongod to as a shard to the mongos instance
# mongos> sh.addShard("bridge-staging-1/bridge-db-1:27017")

node.set['mongodb']['version'] = "3.2.6"
node.set['mongodb']['server_pem'] = "/etc/mongodb/keys/mongodb-server.pem"
node.set['mongodb']['client_pem'] = "/etc/mongodb/keys/mongodb-client.pem"
node.set['mongodb']['bind_ips'] = "#{node['ipaddress']},127.0.0.1"

# Need to remove espy from mongodb cookbook
#include_recipe "chef-mongodb::replicaset"

apt_repository "mongodb" do
  uri "http://repo.mongodb.org/apt/ubuntu"
  distribution "#{node['lsb']['codename']}/mongodb-org/3.2"
  components ["multiverse"]
  keyserver "keyserver.ubuntu.com"
  key "EA312927"
end

apt_package "mongodb-org" do
  version "3.2.6"
  action :install
end

directory "/etc/mongodb" do
  owner "mongodb"
  group "mongodb"
  action :create
end

directory "/data/mongodb/data1" do
  recursive true
  action :create
end

directory "/data/mongodb/data2" do
  recursive true
  action :create
end

directory "/data/mongodb/data3" do
  recursive true
  action :create
end

directory "/data/mongodb/config" do
  recursive true
  action :create
end

template "/etc/mongodb/mongod-1" do
  source 'mongod.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongod-1',
    :listenPort => '27017',
    :replSetName => 'bridge-staging-1',
    :dataDir => '/data/mongodb/data1',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/mongodb/mongod-2" do
  source 'mongod.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongod-2',
    :listenPort => '27117',
    :replSetName => 'bridge-staging-1',
    :dataDir => '/data/mongodb/data2',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/mongodb/mongod-3" do
  source 'mongod.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongod-3',
    :listenPort => '27217',
    :replSetName => 'bridge-staging-1',
    :dataDir => '/data/mongodb/data3',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/mongodb/mongoc-1" do
  source 'mongoc.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongoc-1',
    :listenPort => '27019',
    :dataDir => '/data/mongodb/config-1',
    :replSetName => 'config',
    :oplogSizeMB => '1024',
    :key_file => node['mongodb']['client_pem'],
    :ca_file => node['mongodb']['server_pem']
  })
end

template "/etc/mongodb/mongoc-2" do
  source 'mongoc.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongoc-2',
    :listenPort => '27119',
    :dataDir => '/data/mongodb/config-2',
    :replSetName => 'config',
    :oplogSizeMB => '1024',
    :key_file => node['mongodb']['client_pem'],
    :ca_file => node['mongodb']['server_pem']
  })
end

template "/etc/mongodb/mongoc-3" do
  source 'mongoc.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongoc-3',
    :listenPort => '27219',
    :dataDir => '/data/mongodb/config-3',
    :replSetName => 'config',
    :oplogSizeMB => '1024',
    :key_file => node['mongodb']['client_pem'],
    :ca_file => node['mongodb']['server_pem']
  })
end

template "/etc/mongodb/mongos" do
  variables ({
    :configDB => 'config/bridge-db-1:27019,bridge-db-1:27119,bridge-db-1:27219',
    :instance => 'mongos',
    :listenPort => '27020',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/init/mongod-1.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongod-1',
    :instance => 'mongod-1',
    :mode => 'mongod',
    :daemon => 'mongod',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/init/mongod-2.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongod-2',
    :instance => 'mongod-2',
    :mode => 'mongod',
    :daemon => 'mongod',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end
template "/etc/init/mongod-3.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongod-3',
    :instance => 'mongod-3',
    :mode => 'mongod',
    :daemon => 'mongod',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/init/mongoc-1.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongoc-1',
    :instance => 'mongoc-1',
    :mode => 'mongoc',
    :daemon => 'mongod'
  })
end

template "/etc/init/mongoc-2.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongoc-2',
    :instance => 'mongoc-2',
    :mode => 'mongoc',
    :daemon => 'mongod'
  })
end

template "/etc/init/mongoc-3.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongoc-3',
    :instance => 'mongoc-3',
    :mode => 'mongoc',
    :daemon => 'mongod'
  })
end

template "/etc/init/mongos.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongos',
    :instance => 'mongos',
    :mode => 'mongos',
    :daemon => 'mongos'
  })
end

service "mongod-1" do
  action :start
end

service "mongod-2" do
  action :start
end

service "mongod-3" do
  action :start
end

service "mongoc-1" do
  action :start
end

service "mongoc-2" do
  action :start
end

service "mongoc-3" do
  action :start
end

service "mongos" do
  action :start
end
