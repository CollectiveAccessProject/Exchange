Dir[File.join(Exchange::Application.config.root, '/lib/media_plugins/', '*.rb')].each {|file| require file }

class MediaFile < ActiveRecord::Base
  has_many :change_logs, as: :change_log
  belongs_to :resource

  belongs_to :sourceable, polymorphic: true

  validates :slug, uniqueness: 'Slug is already in use'

  # search
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # slug handling
  include SlugModel
  before_create :set_slug

end
