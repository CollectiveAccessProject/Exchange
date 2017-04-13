module QuickSearchHelper
  def itemsPerPageOptionList
    [
        ["12", 12],
        ["24", 24],
        ["36", 36],
        ["48", 48],
        ["60", 60]
    ]
  end

  def sortOptions(type)

    case
      when (type == 'collection_object')
        return [
            ["Relevance", "_score"],
            ["Title", "title"],
            ["Accession number", "idno"],
            ["Artist", "artist"],
            ["Creation date", "created_at"],
	    ["Date Updated", "updated_at"],
            ["Rating", "rating"]]
      when (type == 'resource')
        return [
            ["Relevance", "_score"],
            ["Title", "title"],
            ["Creation date", "created_at"],
	    ["Date Updated", "updated_at"],
            ["Rating", "rating"]]
      when (type == 'collection')
        return [
            ["Relevance", "_score"],
            ["Title", "title"],
            ["Creation date", "created_at"],
	    ["Date Updated", "upated_at"],
            ["Rating", "rating"]]
      when (type == 'exhibition')
        return [
            ["Relevance", "_score"],
            ["Title", "title"],
            ["Creation date", "created_at"],
            ["Rating", "rating"]]
      else
        return []
    end
  end
end
