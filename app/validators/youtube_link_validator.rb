class YoutubeLinkValidator < ActiveModel::Validator
  def validate(record)
    parsed_url = URI::Parser.new.parse(record.original_link)

    if /youtu.be/.match(parsed_url.to_s)
      #noop
    elsif /embed/.match(parsed_url.to_s)
      #noop
    elsif /\?v=/.match(parsed_url.to_s)
      #noop
    else
      #raise StandardError.new("There was a problem with Youtube format")
      record.errors[:original_link] << "There was an error in Youtube link format"
    end
    
    #case parsed_url.host
    #  when 'youtu.be', 'youtube.com', 'www.youtube.com'
        # noop
    #  else
    #    record.errors[:base] << "This doesn't seem to be a Youtube link"
    #end
  end
end
