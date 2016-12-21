class ResourcesUser < ActiveRecord::Base
  validates :access, inclusion: { in: [1,2] }

  belongs_to :resource
  belongs_to :user

end
