# frozen_string_literal: true

after 'deploy:publishing', 'deploy:restart'

namespace :deploy do
  desc 'Restart puma server'
  task :restart do
    on roles(:app) do
      invoke 'puma:restart'
    end
  end
end

