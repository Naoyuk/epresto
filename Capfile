# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma::Nginx

# Include tasks from other gems included in your Gemfile
require "capistrano/rbenv"
require "capistrano/rails"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
require "capistrano/puma"
install_plugin Capistrano::Puma

require "capistrano/yarn"
require "capistrano/bundler"
# require "capistrano/rvm"
# require "capistrano/chruby"
# require "capistrano/passenger"

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
