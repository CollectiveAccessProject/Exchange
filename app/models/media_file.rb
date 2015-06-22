class MediaFile < ActiveRecord::Base
  has_many :change_logs, as: :change_log
  belongs_to :resource

  validates :slug, uniqueness: 'Slug is already in use'

  has_attached_file :media, :styles => {
                              :medium => { :geometry => '300x300>', :format => 'jpg', :time => 10 },
                              :thumb => { :geometry => '100x100>', :format => 'jpg', :time => 10 }
                          }, :default_url => '/images/:style/missing.png'

  # support, images+pdfs and basic mp4-style videos
  validates_attachment_content_type :media, :content_type => [/\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime']
  validates_with AttachmentPresenceValidator, :attributes => :media
end
