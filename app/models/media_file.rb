class MediaFile < ActiveRecord::Base



    belongs_to :resource, :class_name => 'Resource', :foreign_key => :resource_id
    has_many :media_subfiles, :class_name => 'MediaSubfile'
end
