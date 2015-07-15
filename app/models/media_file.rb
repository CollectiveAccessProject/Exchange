class MediaFile < ActiveRecord::Base
  has_many :change_logs, as: :change_log
  belongs_to :resource
  include ActionView::Helpers

  validates :slug, uniqueness: 'Slug is already in use'

  has_attached_file :media, :styles => {
                              :medium => { :geometry => '300x300>', :format => 'jpg', :time => 10 },
                              :thumb => { :geometry => '100x100>', :format => 'jpg', :time => 10 }
                          }, :default_url => '/images/:style/missing.png'

  # support, images+pdfs and basic mp4-style videos
  validates_attachment_content_type :media, :content_type => [/\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime']
  validates_with AttachmentPresenceValidator, :attributes => :media

  # search
  #include Elasticsearch::Model
  #include Elasticsearch::Model::Callbacks

  # slug handling
  include SlugModel
  before_create :set_slug, :set_mimetype

  def set_mimetype
    self.mimetype = media_content_type
  end

  def get_media_tag
    if /\Aimage\/.*\Z/ =~ media_content_type
      image_tag media.url(:medium)
    elsif /\Avideo\/.*\Z/ =~ media_content_type
      #video_tag media.url, :size => '600x400', controls: true, autobuffer: true
      ''
    elsif /\Aapplication\/pdf\Z/ =~ media_content_type
      image_tag media.url(:medium)
    end
  end
end
