class Link < ActiveRecord::Base
  has_one :resource
  validates :url, presence: true
  validates :url, format: { with: URI.regexp }, if: 'url.present?'

  after_create :set_rank

  def set_rank
    self.rank = self.id
    self.save
  end
end
