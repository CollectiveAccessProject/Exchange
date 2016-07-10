class Link < ActiveRecord::Base
  has_one :resource
  validates :url, presence: true
  validates :url, format: { with: URI.regexp }, if: 'url.present?'
end
