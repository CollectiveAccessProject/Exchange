class FeaturedContentSet < ActiveRecord::Base
  include SlugModel
  include RankModel
  before_create :set_slug

  validates :title, :presence => true

  has_many :featured_content_set_items
end
