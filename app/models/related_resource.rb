class RelatedResource < ActiveRecord::Base
  belongs_to :resources, class_name: "resource", foreign_key: "from_resource_id"
  belongs_to :resources, class_name: "resource", foreign_key: "to_resource_id"
end
