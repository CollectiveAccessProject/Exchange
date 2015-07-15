class Resource < ActiveRecord::Base
  has_many :tags, as: :taggable
  has_many :change_logs, as: :change_log

  belongs_to :parent, class_name: 'Resource', foreign_key: 'parent_id'
  has_many :child_resources, class_name: 'Resource', foreign_key: 'parent_id'

  has_many :related_resources
  has_many :resources, through: 'related_resources'

  belongs_to :forked_from_resource, class_name: 'Resource', foreign_key: 'forked_from_resource_id'
  has_many :forked_resources, class_name: 'Resource', foreign_key: 'forked_from_resource_id'

  belongs_to :user

  # comments via gem
  acts_as_commentable

  # tags via custom module
  include Taggable

  # search
  #include Elasticsearch::Model
  #include Elasticsearch::Model::Callbacks

  validates :slug, uniqueness: 'Slug is already in use'
  validates :resource_type, :presence => true

end
