class YoutubeLinkValidator < ActiveModel::Validator
  def validate(record)
    parsed_url = URI::Parser.new.parse(record.original_link)

    case parsed_url.host
      when 'youtu.be', 'youtube.com', 'www.youtube.com'
        # noop
      else
        record.errors[:base] << "This doesn't seem to be a youtube link"
    end
  end
end

class YoutubeLink < ActiveRecord::Base
  has_one :media_file, as: :sourceable

  include MediaPlugin

  validates_with YoutubeLinkValidator
  before_save :extract_key_from_link

  def extract_key_from_link
    if original_link
      h = CGI::parse(URI::Parser.new.parse(original_link).query)
      self.key = h['v'].first
    end
  end
end

