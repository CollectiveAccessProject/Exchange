class YoutubeLink < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  validates_with YoutubeLinkValidator
  before_save :extract_key_from_link

  def extract_key_from_link
    if original_link
      h = CGI::parse(URI::Parser.new.parse(original_link).query)
      self.key = h['v'].first
    end
  end
end

