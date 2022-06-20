module WelcomeHelper
 def sortOptions()
	return [
		["Relevance", "_score"],
		["Title", "title"],
		["Accession number", "idno"],
		["Artist (Sort on First Name)", "artist"],
		["Date", "start_date"],
		["Rating", "rating"],
		["Creation date", "created_at"],
		["Date Updated", "upated_at"]
	]
  end
end
