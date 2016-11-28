class FeaturedContentSetItem < ActiveRecord::Base
  belongs_to :featured_content_sets
  belongs_to :resource

  include RankModel
  after_create :set_rank

end
