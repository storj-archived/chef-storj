#
# Cookbook Name:: storj
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

group node['storj']['group'] do
  action :create
end

user node['storj']['user'] do
  group node['storj']['group']
  home node['storj']['home']
  manage_home true
  action :create
end
