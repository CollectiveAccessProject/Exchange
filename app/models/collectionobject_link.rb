class CollectionobjectLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with CollectionobjectLinkValidator
  before_save :extract_key_from_link

  #
  # CollectionobjectLink inherits its media, and therefore its thumbnails, from
  # the Collection Object resource it references. No thumbnail generation is done here.
  #

  def extract_key_from_link
    self.resource_id = original_link.to_i
  end

  def get_params
    return { :collectionobject_link => [:original_link]}
  end
end
