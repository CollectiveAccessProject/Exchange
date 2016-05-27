class FlickrLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with FlickrLinkValidator

  before_save :extract_key_from_link

  def extract_key_from_link
    if original_link
      s = URI::Parser.new.parse(original_link).path.match(/\/([0-9]+)/)[1]

      if s.is_a?(String) && (s.length > 0)
        self.photo_id = s.to_i
      end
    end
  end

  def get_params
    return { :flickr_link => [:original_link] }
  end
end