class ResourceParent < ActiveRecord::Base
  belongs_to :resource, class_name: 'Resource', foreign_key: 'parent_resource_id'
  belongs_to :resource, class_name: 'Resource', foreign_key: 'child_resource_id'
end
