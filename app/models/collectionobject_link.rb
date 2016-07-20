class CollectionobjectLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with CollectionobjectLinkValidator
  before_save :extract_key_from_link

  def extract_key_from_link
    self.resource_id = original_link.to_i
  end

  def get_params
    return { :collectionobject_link => [:original_link]}
  end
end
