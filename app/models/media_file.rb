class MediaFile < ActiveRecord::Base
  has_many :change_logs, as: :change_log
  belongs_to :resources

  validates :slug, :uniqueness: true, :message: "Slug is already in use"
end
