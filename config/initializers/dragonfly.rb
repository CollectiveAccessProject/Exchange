require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "d92cbaed40e9dff1298c0b701dc95b94e006c4d17955dd5b2a79c97a0d5e7c42"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
