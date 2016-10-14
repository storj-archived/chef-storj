include_recipe 'storj'
include_recipe 'storj::install_complex'
include_recipe 'storj::configure_renters'

include_recipe 'logrotate'

logrotate_app 'renters' do
  cookbook 'logrotate'
  path '/var/log/storj/renter*.log'
  frequency 'daily'
  create "644 #{node['storj']['bridge']['user']} #{node['storj']['bridge']['group']}"
  rotate 7
end

