require 'bundler/capistrano'

set :application, "foo"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:port] = 2222

role :app, "cthumb.com"
role :web, "cthumb.com"
role :db, "cthumb.com", :primary => true

set :deploy_to, "/home4/laureljt/rails_apps/foo"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:laureljt/foo.git"
set :branch, "master"

set :user, "laureljt"

after "deploy:update_code" do
  run "rm -rf /home4/laureljt/public_html/ruby2/"
  run "ln -s #{release_path}/public /home4/laureljt/public_html/ruby2"
  run "cd #{release_path} ; RAILS_ENV=production bundle exec rake assets:precompile --trace"
end

namespace :deploy do
  task :start, :roles => :app do
    restart
  end
  
  task :restart, :roles => :app do
    run "touch #{File.join(current_path, "tmp", "restart.txt")}"
  end
end