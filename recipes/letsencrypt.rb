include_recipe 'letsencrypt'

letsencrypt_certificate node['bridge']['url'] do
  fullchain "/etc/ssl/certs/#{node['bridge']['url']}.crt"
  key      "/etc/ssl/private/#{node['bridge']['url']}.key"
  method   'http'
  wwwroot  '/tmp/letsencrypt-auto'
end
