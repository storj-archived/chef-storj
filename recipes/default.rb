#
# Cookbook Name:: storj
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'apt'

group node['storj']['group'] do
  action :create
end

user node['storj']['user'] do
  group node['storj']['group']
  home node['storj']['home']
  manage_home true
  action :create
end

case node['platform']
when 'ubuntu'
  case node['platform_version']
  when '14.04'
    node.override['nginx']['init_style'] = 'upstart'
    node.override['storj']['share']['init_style'] = 'upstart'
  when '16.04'
    node.override['nginx']['init_style'] = 'init'
    node.override['storj']['share']['init_style'] = 'systemd'
  end
else
  node.override['nginx']['init_style'] = 'upstart'
  node.override['storj']['share']['init_style'] = 'upstart'
end
