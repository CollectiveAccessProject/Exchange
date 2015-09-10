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

  def external_media_classes
    [YoutubeLink, LocalFile]
  end

  def ext_media_classes_instances
    external_media_classes.map do |p|
      n = p.new
      n.media_file = self if self.id
      n
    end
  end

end
