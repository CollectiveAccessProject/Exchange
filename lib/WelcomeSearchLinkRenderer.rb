module Exchange

	class WelcomeSearchLinkRenderer < WillPaginateInfinite::InfinitePagination
		
		def WelcomeSearchLinkRenderer.set_data(type:, query:)
			@@type  = type if !type.nil?
			@@query  = query if !query.nil?
		end
		def url(page)
			return "/welcome/search/?page=" + page.to_s  + "&query=" + @@query
		end
	end
end