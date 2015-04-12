class ResourceAccess < ActiveRecord::Base
    self.table_name = 'resource_access'

    self.inheritance_column = :ruby_type
    belongs_to :resource, :class_name => 'Resource', :foreign_key => :resource_id
    belongs_to :user_group, :class_name => 'UserGroup', :foreign_key => :user_group_id
    belongs_to :user, :class_name => 'User', :foreign_key => :user_id
end
