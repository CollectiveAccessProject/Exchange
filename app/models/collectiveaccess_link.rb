class CollectiveaccessLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with CollectiveaccessLinkValidator
  before_save :extract_key_from_link
  after_commit :set_thumbnail

  def extract_key_from_link
    if original_link
      h = URI::Parser.new.parse(original_link)
      self.host = h.host
      self.key = /((representation|attribute):([\d:]+))/.match(h.path)
      self.base_url = /^(.*)\/(?=representation|attribute)/.match(original_link)
    end
  end

  def set_thumbnail
    return if !self.media_file
    # TODO: maybe use native resolution?
    #self.media_file.thumbnail_url = self.base_url + self.key + "/full/!2000,2000/0/default.jpg"
    self.media_file.thumbnail_url = self.base_url + self.key + "/full/0/0/default.jpg"
    self.media_file.save
  end

  def get_params
    return { :collectiveaccess_link => [:original_link]}
  end
end
