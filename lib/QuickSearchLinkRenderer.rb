module Exchange

	class QuickSearchLinkRenderer < WillPaginateInfinite::InfinitePagination
		def url(page)
			type = @options[:type]
			query = @options[:query]
			return "/quick_search/query/?type=" + type.to_s + "&page=" + page.to_s + "&query=" + query.to_s
		end
	end
end