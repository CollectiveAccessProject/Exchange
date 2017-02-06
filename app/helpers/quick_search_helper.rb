module QuickSearchHelper
  def itemsPerPageOptionList
    [
        ["12 results per page", 12],
        ["24 results per page", 24],
        ["36 results per page", 36],
        ["48 results per page", 48],
        ["60 results per page", 60]
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
            ["Rating", "rating"]]
      when (type == 'resource')
        return [
            ["Relevance", "_score"],
            ["Title", "title"],
            ["Creation date", "created_at"],
            ["Rating", "rating"]]
      when (type == 'collection')
        return [
            ["Relevance", "_score"],
            ["Title", "title"],
            ["Creation date", "created_at"],
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