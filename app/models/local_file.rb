class LocalFile < ActiveRecord::Base
  include MediaPluginModel
  has_one :media_file, as: :sourceable
  after_commit :set_thumbnail
  #before_save :fetch_file_by_url

  has_attached_file :file, :styles => {
                             # :medium => { :geometry => '300x300>', :format => 'jpg', :time => 10 },
                             # :thumbnail => { :geometry => '100x100>', :format => 'jpg', :time => 10 }
                          },
                    :default_url => '/images/missing.png',
                    :convert_options => { :all => '-auto-orient' }

  # support the following formats:
  # .doc
  # .docx
  # .jpg
  # .jpeg
  # .mov
  # .mp4
  # .mp3
  # .pdf
  # .png
  # .ppt
  # .pptx
  # .xls
  # .xlsx
  validates_attachment_content_type :file, presence: true, content_type:
    [
        /\Aimage\/.*\Z/, 'application/pdf', 'video/mp4', 'video/quicktime', 'audio/mpeg', 'application/msword',
        'application/vnd.ms-excel', 'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation'
    ], message: "Invalid file format"

  # Override file with url if provided
  def fetch_file_by_url
    if (self.url)
     self.file = self.url
    end
  end

  def set_thumbnail
    return if !self.media_file
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
