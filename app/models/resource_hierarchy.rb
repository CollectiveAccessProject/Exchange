class ResourceHierarchy < ActiveRecord::Base
  belongs_to :resource, class_name: 'Resource', foreign_key: :resource_id
  belongs_to :child_resource, class_name: 'Resource', foreign_key: :child_resource_id

  include RankModel
  after_create :set_rank
end