namespace :nginx do
  desc "restart nginx"
  task :restart do
    on roles(:lb) do |host|
      info "Host #{host} (#{host.roles.to_a.join(', ')}):\t start nginx:restart"
      execute :sudo, :systemctl, :restart, :nginx
    end
  end
end

after  'deploy:publishing', 'nginx:restart'
