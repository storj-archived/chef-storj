#
# Cookbook Name:: storj
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

group node['storj']['farmer']['group'] do
  action :create
end

user node['storj']['farmer']['user'] do
  group node['storj']['farmer']['group']
  home node['storj']['farmer']['home']
  manage_home true
  action :create
end
