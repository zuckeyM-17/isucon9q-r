# namespace :mgmt do
#   bundle_cmd = :'/home/isucon/local/ruby/bin/bundle'
# 
#   desc "Bundle install"
#   task :install do
#     on roles(:mgmt) do |host|
#       within "#{release_path}/mgmt" do
#         execute bundle_cmd, :install, :'--path', :'vendor/bundle', :'-j2'
#       end
#     end
#   end
# 
#   desc "restart mgmt"
#   task :restart do
#     on roles(:lb, :web) do |host|
#       execute :sudo, :systemctl, :restart, :mgmt
#     end
#   end
# end
# 
# before 'deploy:updated',    'mgmt:install'
# before 'deploy:reverted',   'mgmt:install'
# after  'deploy:publishing', 'mgmt:restart'
