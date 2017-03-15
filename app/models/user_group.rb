class UserGroup < ActiveRecord::Base
  validates :access_type, inclusion: { in: [1,2] }
  belongs_to :user
  belongs_to :group
end
