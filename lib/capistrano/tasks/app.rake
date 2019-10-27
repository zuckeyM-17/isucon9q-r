namespace :app do
  desc "restart isucari.ruby"
  task :restart do
    on roles(:app) do |host|
      info "Host #{host} start restart app"
      execute :sudo, :systemctl, :restart, :'isucari.ruby'
    end
  end
end

after  'deploy:publishing', 'app:restart'
