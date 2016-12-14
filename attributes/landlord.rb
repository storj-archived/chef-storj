# Infrastructure Config
default['storj']['landlord']['log-dir'] = '/var/log/storj'
default['storj']['landlord']['config-name'] = 'landlord.json'

# Application Config
default['storj']['landlord']['config']['type'] = 'Landlord'
default['storj']['landlord']['config']['opts']['logLevel'] = 2
default['storj']['renter']['config']['opts']['mongoUrl'] = "mongodb://localhost:27017/storj"
default['storj']['renter']['config']['opts']['mongoOpts'] = {}
default['storj']['landlord']['config']['opts']['amqpUrl'] = 'amqp://localhost'
default['storj']['landlord']['config']['opts']['amqpOpts'] = {}
default['storj']['landlord']['config']['opts']['serverPort'] = 8081
default['storj']['landlord']['config']['opts']['serverOpts']['certificate'] = nil
default['storj']['landlord']['config']['opts']['serverOpts']['key'] = nil
default['storj']['landlord']['config']['opts']['serverOpts']['authorization']['username'] = 'storj_user'
default['storj']['landlord']['config']['opts']['serverOpts']['authorization']['password'] = 'thisshouldbeareallyawesomeandhardtoguesspassword'
