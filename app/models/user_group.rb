class UserGroup < ActiveRecord::Base


    self.inheritance_column = :ruby_type
    has_many :resource_accesses, :class_name => 'ResourceAccess'
    has_many :user_group_memberships, :class_name => 'UserGroupMembership'
end
