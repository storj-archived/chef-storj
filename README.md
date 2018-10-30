**Notice: Development on this repository is currently on pause during our v3 rearchitecture. Please see [storj/storj](https://github.com/storj/storj) for ongoing v3 development.**
# Chef Storj

Description
===========
This cookbook deploys and configures the various Storj services. It is intended to be as open minded as possible such that you can build a local dev cluster using chef-zero or deploy production infrastructure.


Changes
=======
## v1.0.0
+ Refactor to match split of bridge services

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
## Default (default.rb)
Attributes used by all services

## Bridge (bridge.rb)
Attributes used by the bridge service

## Bridge DB (bridge_db.rb)
Attributes used by the bridge database setup

## Complex (complex.rb)
Attributes used by the complex service which affects both the landlord and renter

## Landlord (landlord.rb)
Attributes used by the landlord service

## Renter (renter.rb)
Attributes used by the renter service

## Queue (queue.rb)
Attributes used to configure the queue service

## Proxy (proxy.rb)
Attributes used to configure the API proxy service with Nginx

## Share (share.rb)
Attributes used to configure storj-share services

Usage
=====
To install a Storj service, simply include the recipe for the service that you desire to install in a runlist, role or wrapper cookbook recipe and override any attributes as needed. Refer to the matching attributes file for examples and defaults.

For examples of usage, see the Service Recipes section which will include examples of basic usage and will be added over time.

Service Recipes
=======
These are the recipes that you need to run to build a full cluster.

bridge_db
---------
This recipe installs and configures the Bridge api's DB.

Curently, this recipe does not set up the cluster. In the future I will be implementing the mongodb chef cookbook to manage the cluster. Details on that cookbook can be found here: https://github.com/phutchins/chef-mongodb

### Usage

```
include_recipe "storj::bridge_db"
```

bridge_proxy
------------
This recipe installs and configures the Bridge proxy which allows you to run multiple instances of the Bridge behind an Nginx proxy for scalability.

### Usage

```
include_recipe 'storj::bridge_proxy'
```

bridge_queue
------------
This recipe installs and configures the bridge rabbitmq instance.

### Usage

```
node.override['rabbitmq']['default_user'] = 'change_me'
node.override['rabbitmq']['default_pass'] = 'also_change_me'

include_recipe 'chefsj-storj::bridge_queue'
```

bridges
------
This recipe installs and configures instances of the Storj Bridge API.

### Usage
To create a bridge instance (without using the defaults) the minimum required is to
set atleast one attribute in the context of ['bridge']['instances']. The easiest way
to do this is to override the port, even if it is the same as the default port.

```
node.override['storj']['bridge']['instances']['1']['config']['server']['port'] = 8001
include_recipe "storj::bridges"
```

landlord
--------
This recipe installs and configures landlord instances.

### Usage

```
node.override['storj']['landlord']['config']['opts']['amqpUrl'] = 'amqp://myuser:mypass@queue.mydomain.com'
node.override['storj']['landlord']['config']['opts']['serverOpts']['authorization']['password'] = 'amqp://myuser:mypass@queue.mydomain.com'
include_recipe 'storj::landlord'
```

renters
-------
This recipe installs and configures renter instances.

### Usage

```
node.set['storj']['renter']['instances']['1'] = {

}
include_recipe 'chefsj-storj::renters'
```

share
-----
This recipe installs and configures share instances.

### Usage

```
node.set['storj']['share']['storage']['size'] = '60'
include_recipe 'storj::share'
```

Additional Recipes
==================

bridge_db_single
----------------
This recipe is intended to set up a single node with a sharded replica set. This is intended for testing and development.

install_*
---------
These recipes are called by other recipes and are responsible for installing services and dependencies.

configure_*
-----------
These recipes are called by other recipes and are responsible for configuring services.


## Config Server Replica Set
For detailed information on the steps required that are not automated to finish the configuration of the sharded replicaset for MongoDB, take a look at the recipes/bridge_db.rb recipe. The top of this file contains notes on how to complete the setup after the recipe has run.

### Initiate the Replica Set

```
rs.initiate(
  {
    _id: "config",
    configsvr: true,
    members: [
      { _id : 0, host : "bridge-db-g3e3:27019" },
      { _id : 1, host : "bridge-db-ru97:27019" },
      { _id : 2, host : "bridge-db-aokr:27019" }
    ]
  }
)
```

## MongoD Replica Set

### Increase the MongoDB Oplog Size

For an existing cluster, refer to the MongoDB docs (here)[https://docs.mongodb.com/manual/tutorial/change-oplog-size/]...

From a fresh cluster first delete the current oplog.rs db. The instance must not be configured as a replicaset so it must be reconfigured and restarted if it is.

Then create the new capped colleciton setting the size. The following command will create a 10GB oplog. The larger the oplog, the longer you can go with a node down before having to do a full resync to that node. The time frame is dictated by the number and size of transactions that happen per minute on your database.

```
db.runCommand( { create: "oplog.rs", capped: true, size: (10 * 1024 * 1024 * 1024) } )
```

### Initiate the Replia Set
```
rs.initiate(
  {
    _id : "storj-bridge",
      members: [
        { _id : 0, host : "bridge-db-g3e3:27017" },
        { _id : 1, host : "bridge-db-ru97:27017" },
        { _id : 2, host : "bridge-db-aokr:27017" }
      ]
  }
)
```


To Do
=====

+ Automate the setup and configuration of MongoDB replica set and Sharding
+ Automate the creation of self signed keys for MongoDB


Support Operating Systems
=========================
Currently this cookbook only supports Debian like OS's. When Chef enables better conditionals in metadata depends, we will update this to support more systems. PR's are always welcome also.


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
