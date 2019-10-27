#!/home/isucon/local/ruby/bin/ruby

require 'sinatra'
require 'fileutils'

NGINX_ACCESS_LOG = '/var/log/nginx/access.log'

set :bind, '0.0.0.0'

get '/mgmt/nginx_log' do
  body = `cat #{NGINX_ACCESS_LOG}`
  unless $?.exitstatus == 0
    halt 500
  end
  body
end

post '/mgmt/nginx_log/rotate' do
  system("sudo systemctl stop nginx") or halt 500
  system("sudo rm -rf #{NGINX_ACCESS_LOG}") or halt 500
  system("sudo systemctl restart nginx") or halt 500

  "ok"
end
