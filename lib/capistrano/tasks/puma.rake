namespace :puma do
  task :environment do
    set puma_pid, "#{current_path}/tmp/pids/puma.pid"
    set puma_config, "#{current_path}/config/puma.rb"
  end

  def start_puma
    within current_path do
      execute :bundle, :exec, :puma, "-C #{fetch(:puma_config)} -e RAILS_ENV=production"
    end
  end
end
