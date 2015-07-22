module ExchangeMedia
  module Loader
    # there's probably more elegant ways to do this. whatever. it's all tucked away in a module :-)
    def include_media_plugin
      case source_type
        when 'youtube'
          include ExchangeMedia::Youtube
      end
    end
  end
end
