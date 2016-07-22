class Favorite < ActiveRecord::Base
  has_one :resource
  has_one :user
end
