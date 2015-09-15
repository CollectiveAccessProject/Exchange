class VimeoLinkValidator < ActiveModel::Validator
  def validate(record)
    parsed_url = URI::Parser.new.parse(record.original_link)

    case parsed_url.host
      when 'vimeo.com'
        # noop
      else
        record.errors[:base] << "This doesn't seem to be a Vimeo link"
    end
  end
end
