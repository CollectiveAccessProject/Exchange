class LocalFile < ActiveRecord::Base
  belongs_to :media_file, as: :sourceable

  has_attached_file :media, :styles => {
                              :medium => { :geometry => '300x300>', :format => 'jpg', :time => 10 },
                              :thumb => { :geometry => '100x100>', :format => 'jpg', :time => 10 }
                          }, :default_url => '/images/:style/missing.png'

  # support, images+pdfs and basic mp4-style videos
  validates_attachment_content_type :media, :content_type =>
    [/\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime']

  before_create :set_mimetype # for files that are attached directly

  private

  # set mimetype before saving
  def set_mimetype
    if media_content_type
      self.mimetype = media_content_type
    end
  end

end
