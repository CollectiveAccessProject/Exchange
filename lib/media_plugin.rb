module MediaPlugin
  include Plugin

  def self.method_missing(name, *args)
    raise NotImplementedError.new("method #{name} is not implemented for this plugin")
  end
end
