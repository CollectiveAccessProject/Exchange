class MediaFile < ActiveRecord::Base
  belongs_to :resource

  belongs_to :sourceable, polymorphic: true

  validates :slug, uniqueness: 'Slug is already in use'

  # change logging
  has_paper_trail

  # search
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # slug handling
  include SlugModel
  before_create :set_slug

  def sourceable_classes
    MediaPlugin.repository
  end

  def sourceables_underscored
    MediaPlugin.repository.map do |p|
      p.to_s.pluralize.underscore
    end
  end

end
