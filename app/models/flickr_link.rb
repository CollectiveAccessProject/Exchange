class FlickrLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with FlickrLinkValidator

  before_save :extract_key_from_link
  after_commit :set_thumbnail

  def extract_key_from_link
    if original_link
      s = URI::Parser.new.parse(original_link).path.match(/\/([0-9]+)\//)[1]
      if s.is_a?(String) && (s.length > 0)
        self.photo_id = s.to_i
      end

      # cut long links down to size
      self.original_link = original_link.slice(0,255)
    end
  end

  def set_thumbnail
    # Get list of available photo sizes from Flickr
    begin
      p = flickr.photos.getSizes(photo_id: self.photo_id)
    
      if (!(version = p.find {|p| p['label'] == 'Original' }))  # try to use the highest resolution original
        version = p.pop   # otherwise use the last one in the list (presumably the best?)
      end
	rescue
      raise "Can not fetch this image. Access may be restricted by the rights holder."
    end
	
    self.media_file.thumbnail_url = version['source']
    self.media_file.save
  end

  def get_params
    return { :flickr_link => [:original_link] }
  end
end