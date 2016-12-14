include_recipe 'nvm'

nvm_install node['storj']['nodejs']['version'] do
  user_install true
  user node['storj']['bridge']['user']
  user_home node['storj']['bridge']['home']
  from_source false
  alias_as_default true
  action :create
end
