node.set['nginx']['default_site_enabled'] = false

case node['platform']
when 'ubuntu'
  case node['platform_version']
  when '14.04'
    node.override['nginx']['init_style'] = 'upstart'
  when '16.04'
    node.override['nginx']['init_style'] = 'init'
  end
else
  node.override['nginx']['init_style'] = 'upstart'
end

node.override['nginx']['version'] = '1.10.0'
node.override['nginx']['source']['version'] = '1.10.0'
node.override['nginx']['source']['checksum'] = '8ed647c3dd65bc4ced03b0e0f6bf9e633eff6b01bac772bcf97077d58bc2be4d'

include_recipe 'nginx::source'

file '/etc/nginx/sites-enabled/bridge_proxy_https' do
  action :delete
end

file '/etc/nginx/sites-available/bridge_proxy_https' do
  action :delete
end

# Install nginx letsencrypt config and start nginx
nginx_site 'bridge-proxy-http' do
  template 'bridge-proxy-http.erb'
  variables ({
    :url => node['storj']['bridge']['url'],
    :upstream_hosts => node['storj']['bridge']['upstream_hosts']
  })
  notifies :reload, 'service[nginx]', :immediately
end

# Generate SSL certs for bridge proxy
include_recipe 'acme'

acme_certificate node['storj']['bridge']['url'] do
  fullchain "/etc/ssl/certs/#{node['storj']['bridge']['url']}.crt"
  key      "/etc/ssl/private/#{node['storj']['bridge']['url']}.key"
  method   'http'
  wwwroot  '/tmp/letsencrypt-auto'
end

# Once letsencrypt is successful, add nginx bridge proxy config
nginx_site 'bridge-proxy-https' do
  template 'bridge-proxy-https.erb'
  variables ({
    :url => node['storj']['bridge']['url'],
    :upstream_hosts => node['storj']['bridge']['upstream_hosts'],
    :upstream_tunnel_hosts => node['storj']['bridge']['upstream_tunnel_hosts']
  })
  action :nothing
  notifies :reload, 'service[nginx]', :immediately
  subscribes :create, "acme_certificate[#{node['storj']['bridge']['url']}]", :immediately
end
