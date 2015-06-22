class MediaFile < ActiveRecord::Base
  has_many :change_logs, as: :change_log
  belongs_to :resource

  validates :slug, uniqueness: 'Slug is already in use'

  has_attached_file :media, :styles => { :medium => '300x300>', :thumb => '100x100>' }, :default_url => '/images/:style/missing.png'

  validates_attachment_content_type :media, :content_type => [/\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime']
  validates_with AttachmentPresenceValidator, :attributes => :media
end
