namespace :app do
  desc "restart isucari.ruby"
  task :restart do
    on roles(:app) do |host|
      info "Host #{host} start restart app"
      execute :sudo, :systemctl, :restart, :'isucari.ruby'
    end
  end

  desc "copy initial.sql"
  task :copy_file do
    on roles(:app) do |host|
      src = "/home/isucon/initial.sql"
      dst = "isucari/webapp/sql/initial.sql"
      unless File.exists?(dst)
        execute :cp, src, dst
      end
    end
  end
end

after  'deploy:publishing', 'app:restart'
after  'deploy:publishing', 'app:copy_file'
