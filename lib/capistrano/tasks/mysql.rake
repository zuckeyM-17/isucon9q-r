namespace :mysql do
  desc "restart mysql"
  task :restart do
    on roles(:db) do |host|
      info "Host #{host}:\t start mysql:restart"
      execute :sudo, :systemctl, :restart, :mysql
    end
  end

  desc "copy setting"
  task :copy_setting do
    on roles(:db) do |host|
      dst = "/etc/mysql/mysqld.conf"
      src = "#{release_path}/settings#{dst}"
      execute :sudo, :rm, :'-rf', dst
      execute :sudo, :cp, src, dst
    end
  end
end


before 'mysql:restart', 'mysql:copy_setting'
after  'deploy:publishing', 'mysql:restart'
