module ExchangeResource
  module Loader
    # there's probably more elegant ways to do this, but whatever. it's all tucked away in a module :-)
    def include_resource_plugin
      case source_type
        when 'youtube'
          include ExchangeResource::Youtube
      end
    end
  end
end
