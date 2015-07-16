module TaggableModel
  extend ActiveSupport::Concern

  included do
    has_many :tags, as: :taggable
  end

  # tag-related model helper methods can go here
end
