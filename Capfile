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

# Include tasks from other gems included in your Gemfile
require "capistrano/rbenv"
require "capistrano/bundler"
require "capistrano/rails"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/puma"
require "capistrano/yarn"

# Load the Puma plugin
# Learn more about capistrano3-puma on https://github.com/seuros/capistrano-puma
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Nginx

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
