class FlickrLinkValidator < ActiveModel::Validator
  def validate(record)
    parsed_url = URI::Parser.new.parse(record.original_link)

    case parsed_url.host
      when 'www.flickr.com', 'flickr.com'
        # noop
      else
        record.errors[:base] << "This doesn't seem to be a Flickr link"
    end
  end
end
