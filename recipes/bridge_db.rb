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
# Ensure mongodb auth is enabled at this point otherwise auth does nothing
#
# Update hostname on initial host in replica set
# mongod> cfg = rs.conf()
# mongod> cfg.members[0].host = "bridge-db-1:27017"
# rs.reconfig(cfg)
#
# Add the mongod to as a shard to the mongos instance
# mongos> sh.addShard("bridge-staging-1/bridge-db-1:27017")

# Need to remove espy from mongodb cookbook
#include_recipe "chef-mongodb::replicaset"

# Need to manage adding all hosts to to the /etc/hosts file

apt_repository "mongodb" do
  uri "http://repo.mongodb.org/apt/ubuntu"
  distribution "#{node['lsb']['codename']}/mongodb-org/3.2"
  components ["multiverse"]
  keyserver "keyserver.ubuntu.com"
  key "EA312927"
end

apt_package "mongodb-org" do
  version "3.2.10"
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
    :bindIp => node['storj']['bridge']['db']['mongod']['bind_ips'],
    :instance => 'mongod',
    :listenPort => node['storj']['bridge']['db']['mongod']['listen_port'],
    :replSetName => node['storj']['bridge']['db']['mongod']['replset_name'],
    :dataDir => node['storj']['bridge']['db']['mongod']['data_dir'],
    :oplogSizeMB => node['storj']['bridge']['db']['mongod']['oplog_size'],
    :key_file => node['storj']['bridge']['db']['mongod']['server_pem'],
    :enable_ca => node['storj']['bridge']['db']['mongod']['enable_ca'],
    :ca_file => node['storj']['bridge']['db']['mongod']['client_pem'],
    :security_enabled => node['storj']['bridge']['db']['mongod']['security']['enabled'],
    :security_keyfile => node['storj']['bridge']['db']['mongod']['security']['keyFile']
  })
end

template "/etc/mongodb/mongoc" do
  source 'mongoc.erb'
  variables ({
    :bindIp => node['storj']['bridge']['db']['mongoc']['bind_ips'],
    :instance => 'mongoc',
    :listenPort => node['storj']['bridge']['db']['mongoc']['listen_port'],
    :dataDir => node['storj']['bridge']['db']['mongoc']['data_dir'],
    :replSetName => node['storj']['bridge']['db']['mongoc']['replset_name'],
    :oplogSizeMB => node['storj']['bridge']['db']['mongoc']['oplog_size'],
    :key_file => node['storj']['bridge']['db']['mongoc']['client_pem'],
    :enable_ca => node['storj']['bridge']['db']['mongoc']['enable_ca'],
    :ca_file => node['storj']['bridge']['db']['mongoc']['server_pem'],
    :security_enabled => node['storj']['bridge']['db']['mongod']['security']['enabled'],
    :security_keyfile => node['storj']['bridge']['db']['mongod']['security']['keyFile']
  })
end

template "/etc/mongodb/mongos" do
  variables ({
    :bindIp => node['storj']['bridge']['db']['mongos']['bind_ips'],
    :configDB => node['storj']['bridge']['db']['mongos']['config_db'],
    :instance => 'mongos',
    :listenPort => node['storj']['bridge']['db']['mongos']['listen_port'],
    :key_file => node['storj']['bridge']['db']['mongos']['server_pem'],
    :enable_ca => node['storj']['bridge']['db']['mongos']['enable_ca'],
    :ca_file => node['storj']['bridge']['db']['mongos']['client_pem'],
    :security_enabled => node['storj']['bridge']['db']['mongod']['security']['enabled'],
    :security_keyfile => node['storj']['bridge']['db']['mongod']['security']['keyFile']
  })
end

template "/etc/init/mongod.conf" do
  source 'mongo.conf.erb'
  variables ({
    :config => '/etc/mongodb/mongod',
    :instance => 'mongod',
    :daemon => 'mongod',
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

include_recipe 'logrotate'

logrotate_app 'mongodb' do
  cookbook 'logrotate'
  path '/var/log/mongodb/mongo*.log'
  frequency 'daily'
  create "644 #{node['mongodb']['user']} #{node['mongodb']['group']}"
  rotate 7
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
