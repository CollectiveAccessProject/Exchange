class SoundcloudLinkValidator < ActiveModel::Validator
  def validate(record)
    parsed_url = URI::Parser.new.parse(record.original_link)

    case parsed_url.host
      when 'soundcloud.com'
        # noop
      else
        record.errors[:original_link] << "This doesn't seem to be a SoundCloud link"
    end
  end
end
