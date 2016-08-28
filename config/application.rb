require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Exchange
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(
    #{config.root}/lib/middleware
      #{config.root}/lib
      #{config.root}/lib/quickbooks/*
      #{config.root}/lib/**/
      #{config.root}/app/models/concerns
      #{config.root}/app/models/account)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # auto include files in lib/
    config.autoload_paths += %W(#{config.root}/lib)

    # custom Exchange settings
    # that 'x' namespace is predefined and can't be changed :-(
    config.x.license_types = { "All Rights Reserved" =>  0, "Creative Commons by-nc-sa" => 1, "Creative Commons by-nc"=> 2, "Creative Commons by-nc-nd"=> 3, "Creative Commons by"=> 4, "Creative Commons by-sa"=> 5, "Creative Commons by-nd"=> 6, "No copyright restrictions"=> 7, "United States Government work"=> 8 }
    config.x.resource_types = { "Resource"=> 1, "Learning collection"=> 2, "Collection object" => 3, "Exhibition" => 4 }
    config.x.group_types = { basic_group: 1 }
    config.x.access_types = { Published: 1, Unpublished: 0 }

    config.x.user_roles = {"Administrator" => :admin, "Faculty" => :faculty, "Student" => :student}

    # date/time format used to tags, comments, etc.
    config.x.timestamp_format = '%B %e %Y @ %l:%M %p'
  end
end