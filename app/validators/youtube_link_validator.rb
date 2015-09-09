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
