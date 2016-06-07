class RelatedResource < ActiveRecord::Base
  belongs_to :resource, class_name: 'Resource', foreign_key: 'resource_id'
  belongs_to :resource, class_name: 'Resource', foreign_key: 'to_resource_id'
end
