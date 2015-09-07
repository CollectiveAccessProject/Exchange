module MediaPlugin
  include Plugin

  # include all media plugins (i.e. all models)
  Dir[File.join(Exchange::Application.config.root, '/app/models/', '*.rb')].each {|file| require file }

  def self.method_missing(name, *args)
    raise NotImplementedError.new("method #{name} is not implemented for this plugin")
  end
end
