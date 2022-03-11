module Exchange

	class QuickSearchLinkRenderer < WillPaginateInfinite::InfinitePagination
		
		def QuickSearchLinkRenderer.set_data(type:, query:)
			@@type  = type if !type.nil?
			@@query  = query if !query.nil?
		end
		def url(page)
			return "/quick_search/query/?page=" + page.to_s  + "&query=" + @@query + "&type=" + @@type 
		end
	end
end