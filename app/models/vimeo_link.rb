class VimeoLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with VimeoLinkValidator
  before_save :extract_key_from_link

  def extract_key_from_link
    if original_link
      s = URI::Parser.new.parse(original_link).path.gsub /[^0-9]/, ''
      if s.is_a?(String) && (s.length > 0)
        self.key = s
      end
    end
  end


  def get_params
    return { :vimeo_link => [:original_link]}
  end
end
