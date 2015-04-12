class UserGroupMembership < ActiveRecord::Base
    self.table_name = 'user_group_membership'

    self.inheritance_column = :ruby_type
    belongs_to :user_group, :class_name => 'UserGroup', :foreign_key => :user_group_id
    belongs_to :user, :class_name => 'User', :foreign_key => :user_id
end
