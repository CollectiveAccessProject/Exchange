class LocalFile < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable
  after_commit :set_thumbnail

  has_attached_file :file, :styles => {
                              :medium => { :geometry => '300x300>', :format => 'jpg', :time => 10 },
                              :thumbnail => { :geometry => '100x100>', :format => 'jpg', :time => 10 }
                          },
                    :default_url => '/images/missing.png',
                    :convert_options => { :all => '-auto-orient' }

  # support, images+pdfs and basic mp4-style videos
  validates_attachment_content_type :file, :content_type =>
    [/\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime']

  def set_thumbnail
    # TODO: convert non-image formats to images before setting as thumbnail

    if(self.file.path(:original))
     self.media_file.thumbnail = File.new(self.file.path(:original))
      self.media_file.save
    end
  end

  def get_params
    return { :local_file => [:file]}
  end
end
