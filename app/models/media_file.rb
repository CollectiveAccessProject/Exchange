class MediaFile < ActiveRecord::Base
  belongs_to :resource

  belongs_to :sourceable, polymorphic: true, autosave: true

  validates :slug, uniqueness: 'Slug is already in use'

  # change logging
  has_paper_trail

  # search
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # slug handling
  include SlugModel
  before_create :set_slug

  # returns license type as text
  def get_license_type
    return Rails.application.config.x.license_types.key(self.copyright_license)
  end

  # List of supported media "plugins"
  def external_media_classes
    [YoutubeLink, LocalFile, GoogledocsLink, FlickrLink, VimeoLink, SoundcloudLink, CollectiveaccessLink]
  end

  def ext_media_classes_instances
    external_media_classes.map do |p|
      n = p.new
      n.media_file = self if self.id
      n
    end
  end

  def set_sourceable_media(params)
    # Check for params from media plugins
    catch (:done) do
      external_media_classes.map do |plugin|
        instance = plugin.new
        params.permit(instance.get_params) if (params.respond_to?(:permit))

        instance.get_params.each do |n,field_list|
          field_list.each do |f|
          if(params[n] && params[n][f] && (params[n][f].length) > 0)
            instance.original_link = params[n][f]

            self.sourceable = instance

            throw :done
          end
          end

        end
      end
    end


  end

  def as_indexed_json(options = {})
    as_json(
        only: [:id, :slug, :resource_id, :caption, :copyright_notes, :access, :sourceable_type]
    )
  end

  def destroy
    if sourceable
      sourceable.destroy
    end

    begin
      super
    rescue
      # noop
    end
  end
end