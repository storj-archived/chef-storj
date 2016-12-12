include_recipe 'acme'

acme_certificate node['storj']['bridge']['url'] do
  fullchain "/etc/ssl/certs/#{node['storj']['bridge']['url']}.crt"
  key      "/etc/ssl/private/#{node['storj']['bridge']['url']}.key"
  method   'http'
  wwwroot  '/tmp/letsencrypt-auto'
end
