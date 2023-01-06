# frozen_string_literal: true

set :stage, :production
server ENV['PRODUCTION_HOST'], user: 'epresto', roles: %w(web app db)
