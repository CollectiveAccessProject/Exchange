class GoogledocsLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with GoogledocsLinkValidator
end
