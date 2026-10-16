lock '3.16.0'

set :application, 'bulk_order'
set :repo_url, 'git@github.com:socialimprints/bulk-order-shopify-app.git'
set :deploy_to, '/var/www/apps/bulk_order'
set :keep_releases, 3
set :format, :pretty
set :log_level, :debug
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :passenger_restart_with_touch, true

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :ssh_options, {
  forward_agent: true
}

namespace :deploy do

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        execute :touch, release_path.join('tmp/restart.txt')
      end
    end
  end

end

namespace :delayed_job do

  desc 'Restart delayed job'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'bin/delayed_job', :restart
        end
      end
    end
  end

end

after 'deploy:publishing', 'deploy:restart'
after "deploy:restart", "delayed_job:restart"
