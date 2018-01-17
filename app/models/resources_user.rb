class ResourcesUser < ActiveRecord::Base
  validates :access, inclusion: { in: [1,2] }

  belongs_to :resource
  belongs_to :user
  has_many :user_group, :primary_key => :user_id, :foreign_key => :user_id

  after_commit do |rel|
    # force reindex of related resource
    r = Resource.find(rel.resource_id)
    r.touch
  end

end
