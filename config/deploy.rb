require 'bundler/capistrano'

set :default_environment, {
  'RBENV_ROOT' => '/usr/local/rbenv',
  'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
}
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
set :use_sudo, false

set :application, 'tracker'
set :deploy_to, '/Users/dixonb/Sites/tracker'
set :passenger_port, '8080'

set :scm, :git
set :repository, 'git@github.com:aws/tracker.git'
# set :branch, 'origin/master'
set :git_shallow_clone, 1
set :deploy_via, :remote_cache
set :keep_releases, 5

server 'localhost', :app, :web, :db, primary: true

after 'deploy:update_code', 'deploy:migrate'
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  # task :default do
  #   update
  #   restart
  #   cleanup
  # end
  # 
  # desc "Setup a GitHub-style deployment."
  # task :setup, except: {no_release: true} do
  #   run "git clone #{repository} #{current_path}"
  # end
  # 
  # desc "Update the deployed code."
  # task :update_code, except: {no_release: true} do
  #   run "cd #{current_path}; git fetch origin; git reset --hard #{branch}"
  # end
  # 
  # desc "Rollback a single commit."
  # task :rollback, except: {no_release: true} do
  #   set :branch, "HEAD^"
  #   default
  # end

  task :start do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec passenger start -d -p #{passenger_port}"
  end
  
  task :stop do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec passenger stop -p #{passenger_port}"
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop rescue nil
    start
    # run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
