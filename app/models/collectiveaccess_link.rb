class CollectiveaccessLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with CollectiveaccessLinkValidator
  before_save :extract_key_from_link

  def extract_key_from_link
    if original_link
      h = URI::Parser.new.parse(original_link)
      self.host = h.host
      self.key = /((representation|attribute):([\d:]+))/.match(h.path)
      self.base_url = /^(.*)\/(?=representation|attribute)/.match(original_link)
    end
  end

  def get_params
    return { :collectiveaccess_link => [:original_link]}
  end
end
