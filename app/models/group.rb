class Group < ActiveRecord::Base
  has_many :user_groups
  has_many :users, :through => :user_groups

  # slug handling
  include SlugModel
  before_create :set_slug

  def self.group_types
    Rails.application.config.x.group_types
  end
end
