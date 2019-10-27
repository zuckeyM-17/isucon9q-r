# capistrano-bundler seems not for us because our app is not located in root_path.
# So let's introduce a new job.
# Note that this job starts with 'bundle', not 'bundler'.
# This is because capistrano-bundler uses 'bundler' and it is confusing for this task to use 'bundler'.
namespace :bundle do
  # Use this as `bundle`. Without this, capistrano tries to use `/usr/bin/env bundle` and it fails
  bundle_cmd = :'/home/isucon/local/ruby/bin/bundle'

  desc "Bundle install"
  task :install do
    on roles(:app) do |host|
      info "Host #{host} (#{host.roles.to_a.join(', ')}):\t start bundle"
      within "#{release_path}/isucari/webapp/ruby" do
        execute bundle_cmd, :install, :'--path', :'vendor/bundle', :'-j2'
      end
    end
  end
end

before 'deploy:updated', 'bundle:install'
before 'deploy:reverted', 'bundle:install'
