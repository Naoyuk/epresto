# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.17.1'

# capistranoデフォルトタスク
set :application, 'epresto'
set :repo_url, 'git@github.com:Naoyuk/epresto.git'
set :branch, 'main'
set :deploy_to, "/home/epresto/#{fetch(:application)}"
set :linked_files, %w(.env config/master.key)
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets)
puts ENV.fetch("DEPLOY_SSH_KEY_PATH", 'error')
set :ssh_options, {
  keys: [ENV.fetch("DEPLOY_SSH_KEY_PATH", "~/.ssh/id_rsa")],
  forward_agent: true,
  auth_methods: %w(publickey)
}
set :keep_releases, 5

# capistrano-rails
set :rails_env, 'production'
# set :log_level, :debug

# capistrano-rbenv
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"

# capistrano-puma
set :puma_threads, [0, 5]
set :puma_workers, 2

# Rails assets manifest file
set :assets_manifests, -> {
  [release_path.join("public", fetch(:assets_prefix), '.manifest.json')]
}
# namespace :puma do
#   desc 'Create Directories for Puma Pids and Socket'
#   task :make_dirs do
#     on roles(:app) do
#       execute "mkdir #{shared_path}/tmp/sockets -p"
#       execute "mkdir #{shared_path}/tmp/pids -p"
#     end
#   end
#   before :start, :make_dirs
# end
# 
# namespace :deploy do
#   desc 'Make sure local git is in sync with remote.'
#   task :check_revision do
#     on roles(:app) do
#       unless `git rev-parse HEAD` == `git rev-parse origin/main`
#         puts 'WARNING: HEAD is not the same as origin/main'
#         puts 'Run `git push` to sync changes.'
#         exit
#       end
#     end
#   end
#   desc 'Initial Deploy'
#   task :initial do
#     on roles(:app) do
#       before 'deploy:restart', 'puma:start'
#       invoke 'deploy'
#     end
#   end
#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       invoke 'puma:restart'
#     end
#   end
#   before :starting, :check_revision
#   after :finishing, :compile_assets
#   after :finishing, :cleanup
#   after :finishing, :restart
# end
# 
# namespace :config do
#   task :display do
#     Capistrano::Configuration.env.keys.each do |key|
#       p "#{key} => #{fetch(key)}"
#     end
#   end
# end
