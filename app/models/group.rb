class Group < ActiveRecord::Base
  has_many :user_groups,  :dependent => :destroy
  has_many :users, :through => :user_groups
  belongs_to :user

  # slug handling
  include SlugModel
  before_create :set_slug

  def self.group_types
    Rails.application.config.x.group_types
  end
end
