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
    on roles(:db) do |host|
      src = "/home/isucon/initial.sql"
      dst = "isucari/webapp/sql/initial.sql"
      execute :rm, '-rf', dst
      execute :cp, src, dst
    end
  end

  desc "create a symlink to upload "
  task :link_upload do
    on roles(:app) do |host|
      execute :mkdir, :"-p", "/home/isucon/upload"
      execute :ln, :"-s", "/home/isucon/upload", "isucari/webapp/public/upload"
    end
  end
end

after  'deploy:publishing', 'app:restart'
after  'deploy:publishing', 'app:copy_file'
after  'deploy:publishing', 'app:link_upload'
