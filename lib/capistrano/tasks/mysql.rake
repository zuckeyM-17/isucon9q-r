namespace :mysql do
  desc "restart mysql"
  task :restart do
    on roles(:db) do |host|
      info "Host #{host}:\t start mysql:restart"
      execute :sudo, :systemctl, :restart, :mysql
    end
  end
end


after  'deploy:publishing', 'mysql:restart'
