include_recipe "storj"

# Generating SSL certs and keys...
# openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-server-cert.crt -keyout mongodb-server-cert.key
#  openssl req -newkey rsa:2048 -new -x509 -days 365 -nodes -out mongodb-client-cert.crt -keyout mongodb-client-cert.key
# cat mongodb-server-cert.key mongodb-server-cert.crt > mongodb-server.pem
# cat mongodb-client-cert.key mongodb-client-cert.crt > mongodb-client.pem
# Copy server and client pem into /etc/mongodb/keys
# We use server pem on the mongod instance for key and client as the ca, then reverse for
# any clients including mongos and config servers
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

directory "/data/mongodb/data" do
  recursive true
  owner "mongodb"
  group "mongodb"
  action :create
end

directory "/data/mongodb/config" do
  recursive true
  owner "mongodb"
  group "mongodb"
  action :create
end

template "/etc/mongodb/mongod" do
  source 'mongod.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongod',
    :listenPort => '27017',
    :replSetName => node['storj']['bridge']['db']['mongod']['replset_name'],
    :dataDir => '/data/mongodb/data',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/mongodb/mongoc" do
  source 'mongoc.erb'
  variables ({
    :bindIp => node['mongodb']['bind_ips'],
    :instance => 'mongoc',
    :listenPort => '27019',
    :dataDir => '/data/mongodb/config',
    :replSetName => 'config',
    :oplogSizeMB => '1024',
    :key_file => node['mongodb']['client_pem'],
    :ca_file => node['mongodb']['server_pem']
  })
end

template "/etc/mongodb/mongos" do
  variables ({
    :configDB => node['storj']['bridge']['db']['mongos']['config_db'],
    :instance => 'mongos',
    :listenPort => '27020',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/init/mongod.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongod',
    :instance => 'mongod',
    :mode => 'mongod',
    :daemon => 'mongod',
    :key_file => node['mongodb']['server_pem'],
    :ca_file => node['mongodb']['client_pem']
  })
end

template "/etc/init/mongoc.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongoc',
    :instance => 'mongoc',
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

service "mongod" do
  action :start
end

service "mongoc" do
  action :start
end

service "mongos" do
  action :start
end
