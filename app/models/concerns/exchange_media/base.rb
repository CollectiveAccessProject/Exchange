module ExchangeMedia
  module Base
    def self.included(base)
      puts base.inspect
      base.extend(ClassMethods)
    end

    # class methods related to exchange media functionality
    # these ultimately extend the media file model and should be
    # callable like this: MediaFile.foo
    module ClassMethods

    end
  end
end
