module CopyrightModel
  extend ActiveSupport::Concern

  class_methods do
    def license_types
      Rails.application.config.x.license_types
    end
  end

end
