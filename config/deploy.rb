# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"

set :application, "epresto"
set :repo_url, "git@github.com:Naoyuk/epresto.git"
set :branch, 'main'
set :deploy_to, "/var/www/epresto"
set :linked_files, %w(config/master.key)
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)
set :rbenv_ruby, '3.1.2'
set :log_level, :debug

# set :passenger_restart_with_touch, true
# set :rails_env, :development
# set :puma_threads, [4, 16]
# set :pty, true
# set :use_sudo, false
# set :stage, :production
# set :deploy_via, :remote_cache
# set :puma_bind, "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
# set :puma_state, "#{shared_path}/tmp/pids/puma.state"
# set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
# set :puma_access_log, "#{release_path}/log/puma.error.log"
# set :puma_error_log, "#{release_path}/log/puma.access.log"
# set :puma_preload_app, true
# set :puma_worker_timeout, nil
# set :puma_init_active_record, false

# namespace :puma do
#  desc "Create Directories for Puma Pids and Socket"
#  task :make_dirs do
#    on roles(:app) do
#      execute "mkdir #{shared_path}/tmp/sockets -p"
#      execute "mkdir #{shared_path}/tmp/pids -p"
#    end
#  end
# 
#   before :start, :make_dirs
# end
# 
# namespace :deploy do
#  desc "Make sure local git is in sync with remote."
#  task :check_revision do
#    on roles(:app) do
#       unless `git rev-parse HEAD` == `git rev-parse origin/master`
#         puts "WARNING: HEAD is not the same as origin/master"
#         puts "Run `git push` to sync changes."
#         exit
#       end
#    end
#  end
# 
#   desc "Initial Deploy"
#   task :initial do
#     on roles(:app) do
#       before "deploy:restart", "puma:start"
#       invoke "deploy"
#     end
#   end
# 
#   desc "Restart application"
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       invoke "puma:restart"
#     end
#   end
# 
#   before :starting, :check_revision
#   after :finishing, :compile_assets
#   after :finishing, :cleanup
#   after :finishing, :restart
# end
