class GoogledocsLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with GoogledocsLinkValidator


  def get_params
    return { :googledocs_link => [:original_link]}
  end
end
