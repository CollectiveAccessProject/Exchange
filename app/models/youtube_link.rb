class YoutubeLink < ActiveRecord::Base
  has_one :media_file, as: :sourceable

  include MediaPlugin
end
