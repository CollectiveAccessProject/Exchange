class SoundcloudLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with SoundcloudLinkValidator


  def get_params
    return { :soundcloud_link => [:original_link] }
  end
end
