class Resource < ActiveRecord::Base
  has_many :tags, as: :taggable
  has_many :change_logs, as: :change_log

  belongs_to :parent, class_name: 'Resource', foreign_key: 'parent_id'
  has_many :child_resources, class_name: 'Resource', foreign_key: 'parent_id'

  has_many :related_resources
  has_many :resources, through: 'related_resources'
  has_many :media_files

  belongs_to :forked_from_resource, class_name: 'Resource', foreign_key: 'forked_from_resource_id'
  has_many :forked_resources, class_name: 'Resource', foreign_key: 'forked_from_resource_id'

  belongs_to :user

  # comments via gem
  acts_as_commentable

  # tags via custom module
  include Taggable

  # copyright instance methods
  include CopyrightModel
  # copyright class methods
  # there are hacks to make this implicit in the include call above, but many
  # people recommend keeping it separate so you can actually see what's going on
  extend CopyrightModel::ClassMethods

  # search
  #include Elasticsearch::Model
  #include Elasticsearch::Model::Callbacks

  # basic model validations
  validates :slug, uniqueness: 'Slug is already in use'
  validates :resource_type, :presence => true

  # slug handling
  include SlugModel
  before_create :set_slug

  def self.resource_types
    Rails.application.config.x.resource_types
  end
end
