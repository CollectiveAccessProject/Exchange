class ResourcesGroup < ActiveRecord::Base
    validates :access, inclusion: { in: [1,2] }

    belongs_to :resource
    belongs_to :group
    has_many :user_groups, through: :group
end
