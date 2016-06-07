class CollectiveaccessLinkValidator < ActiveModel::Validator
  def validate(record)
    parsed_url = URI::Parser.new.parse(record.original_link)

    if (/\/service.php\/IIIF/.match(parsed_url.path) && /\/(representation|attribute)[\d:]+/.match(parsed_url.path))
        # noop
    else
        record.errors[:base] << "This doesn't seem to be a CollectiveAccess media link"
    end
  end
end
