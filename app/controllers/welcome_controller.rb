class WelcomeController < ApplicationController
  def index
    @featured_content_set = FeaturedContentSet.where(slug: "front-page", access: 1).first
  end
end