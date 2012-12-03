require 'bundler/capistrano'

set :application, 'tracker'
set :deploy_to, '/Users/dixonb/Sites/tracker'

set :scm, :git
set :repository, 'git@github.com:aws/tracker.git'
set :git_shallow_clone, 1
set :deploy_via, :remote_cache

set :keep_releases, 5

server 'localhost', :app, :web, :db, primary: true

after 'deploy:update_code', 'deploy:migrate'
after "deploy:restart", "deploy:cleanup"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
