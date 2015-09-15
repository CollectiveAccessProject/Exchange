class SoundcloudLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with SoundcloudLinkValidator
end
