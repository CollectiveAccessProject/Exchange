class UserGroup < ActiveRecord::Base
  validates :access_type, inclusion: { in: [1,3] }
  belongs_to :user
  belongs_to :group
end
