module CopyrightModel

  module ClassMethods
    def license_types
      Rails.application.config.x.license_types
    end
  end

end
