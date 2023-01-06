# frozen_string_literal: true

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Include console task
require 'capistrano/console'

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# capistrano-rbenv
require "capistrano/rbenv"

# capistrano-rails
require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"

# capistrano-puma
require "capistrano/puma"
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Daemon
install_plugin Capistrano::Puma::Nginx

# capistrano-yarn
require "capistrano/yarn"


# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
