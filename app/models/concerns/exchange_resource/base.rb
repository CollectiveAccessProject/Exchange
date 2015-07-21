module ExchangeResource
  module Base
    def self.included(base)
      puts base.inspect
      base.extend(ClassMethods)
    end

    # class methods related to exchange resource functionality
    # these ultimately extend the resource model and should be
    # callable like this: Resource.foo
    module ClassMethods
      def lookup(*args)
        opts = args.extract_options!
        case opts[:plugin]
          when :youtube
            ExchangeResource::Youtube::lookup opts
          else
            puts 'else'
        end
      end
    end

  end
end
