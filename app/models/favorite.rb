class Favorite < ActiveRecord::Base
  belongs_to :resource, foreign_key: :resource_id
  belongs_to :user, foreign_key: :user_id

end
