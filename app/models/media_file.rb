Dir[File.join(Exchange::Application.config.root, '/lib/media_plugins/', '*.rb')].each {|file| require file }

class MediaFile < ActiveRecord::Base
  has_many :change_logs, as: :change_log
  belongs_to :resource
  attr_accessor :source_instance # this may have to be just a reader, not sure yet
  include ActionView::Helpers

  validates :slug, uniqueness: 'Slug is already in use'

  has_attached_file :media, :styles => {
                              :medium => { :geometry => '300x300>', :format => 'jpg', :time => 10 },
                              :thumb => { :geometry => '100x100>', :format => 'jpg', :time => 10 }
                          }, :default_url => '/images/:style/missing.png'

  # support, images+pdfs and basic mp4-style videos
  validates_attachment_content_type :media, :content_type =>
    [/\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime']

  # search
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # slug handling
  include SlugModel
  before_create :set_slug

  # media
  before_create :set_mimetype # for files that are attached directly
  after_initialize :init_media_plugin # for things referenced by plugin

  before_save :save_media_plugin_settings # transfer media plugin settings to 'source' field

  # get media tag for display
  def get_media_tag
    if /\Aimage\/.*\Z/ =~ media_content_type
      image_tag media.url(:medium)
    # this for some reason crashes my browser right now ... will have to investigate later
    #elsif /\Avideo\/.*\Z/ =~ media_content_type
      #video_tag media.url, :size => '600x400', controls: true, autobuffer: true
    elsif /\Aapplication\/pdf\Z/ =~ media_content_type
      image_tag media.url(:medium)
    end

    ''
  end

  private
    # set mimetype before saving
    def set_mimetype
      if media_content_type
        self.mimetype = media_content_type
      end
    end

    # always keep the media plugin instance handy, if source_type is available
    def init_media_plugin
      if source_type == nil
        return
      end

      if source_type.constantize.respond_to?(:init_from_settings)
        @source_instance = source_type.constantize.init_from_settings(source)
      end
    end

    # transfer media plugin settings JSON to 'source' field
    def save_media_plugin_settings
      if source_instance
        self.source = source_instance.to_json
      end
    end
end
