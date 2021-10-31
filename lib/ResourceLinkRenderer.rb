module Exchange

	class ResourceLinkRenderer < WillPaginateInfinite::InfinitePagination
		
		def ResourceLinkRenderer.set_data(query:)
			@@resource_query = nil
			@@resource_query = query if !query.nil?
		end
		def url(page)
			return "/quick_search/query/?type=resource&page=" + page.to_s + "&query=" + @@resource_query.to_s
		end
	end
end