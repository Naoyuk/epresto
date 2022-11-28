# frozen_string_literal: true

# set :puma_sock, "unix://#{shared_path}/sockets/puma.sock"
# set :puma_control, "unix://#{shared_path}/sockets/pumactl.sock"
set :puma_state, "#{fetch(:deploy_to)}/shared/tmp/pids/puma.state"
set :puma_log, "#{fetch(:deploy_to)}/shared/log/puma-#{fetch(:stage)}.log"

namespace :puma do
  task :environment do
    set :puma_pid, "#{current_path}/tmp/pids/server.pid"
    set :puma_config, "#{current_path}/config/puma.rb"
  end

  def start_puma
    within current_path do
      exucute :bundle, :exec, :puma, "-b 'unix://#{shared_path}/sockets/puma.sock' -e #{fetch(:stage)} -t 1:32 -w 2 --control 'unix://#{shared_path}/sockets/pumactl.sock' -S #{fetch(:puma_state)} >> #{fetch(:puma_log)} 2>&1 &"
    end
  end

  def stop_puma
    execute :bundle, :exec, :pumactl, "-e #{fetch(:stage)} -S #{fetch(:puma_state)} stop"
  end

  def restart_puma
    execute :bundle, :exec, :pumactl, "-e #{fetch(:stage)} -S #{fetch(:puma_state)} restart"
  end

  def status_puma
    execute :bundle, :exec, :pumactl, "-e #{fetch(:stage)} -S #{fetch(:puma_state)} stats"
  end

  desc 'Start puma server'
  task start: :environment do
    on roles(:app) do
      start_puma
    end
  end

  desc 'Stop puma server gracefully'
  task stop: :environment do
    on roles(:app) do
      stop_puma
    end
  end

  desc 'Restart puma server gracefully'
  task restart: :environment do
    on roles(:app) do
      if test("[ -f #{fetch(:puma_pid)} ]")
        restart_puma
      else
        start_puma
      end
    end
  end

  desc 'Check puma server status'
  task status: :environtment do
    on roles(:app) do
      status_puma
    end
  end
end
