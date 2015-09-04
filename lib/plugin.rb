# generic plugin module
module Plugin
  module ClassMethods
    def repository
      @repository ||= []
    end

    def included(klass)
      repository << klass
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end
end
