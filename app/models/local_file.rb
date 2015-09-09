class LocalFile < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable

  has_attached_file :file, :styles => {
                              :medium => { :geometry => '300x300>', :format => 'jpg', :time => 10 },
                              :thumb => { :geometry => '100x100>', :format => 'jpg', :time => 10 }
                          }, :default_url => '/images/:style/missing.png'

  # support, images+pdfs and basic mp4-style videos
  validates_attachment_content_type :file, :content_type =>
    [/\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime']
end
