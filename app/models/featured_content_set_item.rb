class FeaturedContentSetItem < ActiveRecord::Base
  belongs_to :featured_content_sets
  belongs_to :resource

end
