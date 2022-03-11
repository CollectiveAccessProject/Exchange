class WelcomeController < ApplicationController
  def index

    @is_staff = current_user && current_user.has_role?(:staff)
    @featured_content_set = FeaturedContentSet.where(slug: "front-page", access: 1).first
    
    @suggested_search_terms = [
    	"rivers and streams",
    	"japanese pottery",
    	"fashion photography",
    	"abstract expressionism",
    	"hudson school",
    	"puppies"
    ].sample(3)
  end
end