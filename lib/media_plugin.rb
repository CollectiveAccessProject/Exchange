class MediaPlugin
  include Plugin

  # include all media plugins
  Dir[File.join(Exchange::Application.config.root, '/lib/media_plugins/', '*.rb')].each {|file| require file }

  def self.method_missing(name, *args)
    raise NotImplementedError.new("method #{name} is not implemented for this plugin")
  end
end
