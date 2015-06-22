class MediaFile < ActiveRecord::Base
  has_many :change_logs, as: :change_log
  belongs_to :resource

  validates :slug, uniqueness: 'Slug is already in use'
end
