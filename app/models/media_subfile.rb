class MediaSubfile < ActiveRecord::Base



    belongs_to :media_file, :class_name => 'MediaFile', :foreign_key => :media_id
end
