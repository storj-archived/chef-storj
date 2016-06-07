node.set['nginx']['default_site_enabled'] = false
node.override['nginx']['init_style'] = 'upstart'
node.override['nginx']['version'] = '1.10.0'
node.override['nginx']['source']['version'] = '1.10.0'
node.override['nginx']['source']['checksum'] = '8ed647c3dd65bc4ced03b0e0f6bf9e633eff6b01bac772bcf97077d58bc2be4d'

include_recipe 'nginx::source'

# Install nginx letsencrypt config and start nginx
nginx_site 'bridge-proxy-http' do
  template 'bridge-proxy-http.erb'
  variables ({
    :url => node['bridge']['url'],
    :upstream_hosts => node['bridge']['upstream_hosts']
  })
  notifies :reload, 'service[nginx]', :immediately
end

# Generate SSL certs for bridge proxy
include_recipe 'letsencrypt'

letsencrypt_certificate node['bridge']['url'] do
  fullchain "/etc/ssl/certs/#{node['bridge']['url']}.crt"
  key      "/etc/ssl/private/#{node['bridge']['url']}.key"
  method   'http'
  wwwroot  '/tmp/letsencrypt-auto'
  notifies :create, "letsencrypt_certificate[#{node['bridge']['url']}]", :immediately
end

# Once letxencrypt is successful, add nginx bridge proxy config
nginx_site 'bridge-proxy-https' do
  template 'bridge-proxy-https.erb'
  variables ({
    :url => node['bridge']['url'],
    :upstream_hosts => node['bridge']['upstream_hosts']
  })
  action :nothing
  notifies :reload, 'service[nginx]', :immediately
end

