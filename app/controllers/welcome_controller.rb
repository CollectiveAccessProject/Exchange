class WelcomeController < ApplicationController
  def index

    @is_staff = current_user && current_user.has_role?(:staff)
    @featured_content_set = FeaturedContentSet.where(slug: "front-page", access: 1).first
  end
end