Description
===========
This cookbook deploys and configures the various Storj services. It is intended to be as open minded as possible such that you can build a local dev cluster using chef-zero or deploy production infrastructure.


Changes
=======
## v 0.1.1
+ Rename cookbooks to use underscores
+ Rename all instances of farmer to share
+ Move bridge, bridge-proxy and bridge-db recipes to this cookbook

## v 0.1.0

Requirements
============
+ A computer or something that closely resembles one

Attributes
==========
## Default
```
default['storj']['user'] = 'storj'
default['storj']['group'] = 'storj'
default['storj']['home'] = '/opt/storj'
```

## Bridge
```
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
default['storj']['bridge']['server-port'] = 8080,
default['storj']['bridge']['server-ssl-cert'] = true
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
```

## Share
```
default['storj']['share']['user'] = 'storj'
default['storj']['share']['group'] = 'storj'
default['storj']['share']['home'] = node['storj']['home']
default['storj']['share']['version'] = 'v0.7.3'
default['storj']['share']['app_dir'] = "#{node['storj']['share']['home']}/share"
default['storj']['share']['log_dir'] = '/var/log/storj'
default['storj']['share']['log_file'] = 'share.log'
default['storj']['share']['repo'] = 'https://github.com/Storj/storjshare-cli.git'
default['storj']['share']['node_env'] = 'production'
default['storj']['share']['revision'] = 'HEAD'
default['storj']['share']['node_index'] = 'bin/farmer.js'
default['storj']['share']['password'] = 'thisshouldbeasupersecurepasswordforyourfarmer'
default['storj']['share']['data_dir'] = '.storjshare'
default['storj']['share']['key_file'] = 'id_ecdsa'
default['storj']['share']['payment_address'] = '12sudHQtCt8Wp9X7V9U69CjzG6SFCKvgEZ'
default['storj']['share']['storage']['size'] = 10
default['storj']['share']['storage']['unit'] = 'GB'
default['storj']['share']['network']['port'] = 4000
default['storj']['share']['network']['seeds'] = [ "storj://api.storj.io:8443/593844dc7f0076a1aeda9a6b9788af17e67c1052" ]
default['storj']['share']['network']['forward'] = 'true'
default['storj']['share']['network']['tunnels'] = 10
default['storj']['share']['network']['tunnelport'] = 8444
default['storj']['share']['network']['gateways']['min'] = 8500
default['storj']['share']['network']['gateways']['max'] = 8520
default['storj']['share']['telemetry']['service'] = 'http://status.storj.io'
default['storj']['share']['telemetry']['enabled'] = 'true'
```

Recipes
=======
bridge
------
This recipe installs and configures the Storj Bridge API.

bridge_db
---------
This recipe installs and configures the Bridge api's DB.

bridge_proxy
------------
This recipe installs and configures the Bridge proxy which allows you to run multiple instances of the Bridge behind an Nginx proxy for scalability.

share
-----
This recipe installs and configures the StorjShare farmer.


default
-------
This recipe sets up the user and group used by all Storj services.

Resources/Providers
===================
In the future we will likely move all install_X recipes to resource providers.


Usage
=====
To install a Storj service, simply include the recipe for the service that you desire to install in a runlist, role or wrapper cookbook recipe and override any attributes as needed.


Examples
--------
Better usage examples coming soon...

License and Author
==================

Author:: Philip Hutchins

Copyright:: 2016, Storj Labs

Licensed under the AGPL License, Version 3.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.gnu.org/licenses/agpl-3.0.en.html

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
