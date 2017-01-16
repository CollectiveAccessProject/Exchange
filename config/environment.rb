# Load the Rails application.
require File.expand_path('../application', __FILE__)

app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
load(app_environment_variables) if File.exists?(app_environment_variables)

# Initialize the Rails application.
Rails.application.initialize!

require 'exchange/exchange_file_system_file_resolver'
Riiif::Image.file_resolver = Exchange::ExchangeFileSystemFileResolver.new
Riiif::Image.file_resolver.base_path = [Rails.root, 'public', 'system', 'dragonfly'].join('/')