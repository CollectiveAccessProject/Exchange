class CollectionobjectLinkValidator < ActiveModel::Validator
  def validate(record)
    r =  Resource.find(record.original_link.to_i)
    if ((r) && r.is_collection_object)
      return true
    end

    record.errors[:base] << "This doesn't seem to be a collection object media link"
    return false
  end
end