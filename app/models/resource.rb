class Resource < ActiveRecord::Base



    has_many :links, :class_name => 'Link'
    has_many :media_files, :class_name => 'MediaFile'
    has_many :related_resources, :class_name => 'RelatedResource'
    has_many :related_resources, :class_name => 'RelatedResource'
    has_many :resource_accesses, :class_name => 'ResourceAccess'
    has_many :resource_transitions, :class_name => 'ResourceTransition'
    has_many :resource_transitions, :class_name => 'ResourceTransition'
    belongs_to :user, :class_name => 'User', :foreign_key => :user_id
    belongs_to :resource, :class_name => 'Resource', :foreign_key => :parent_id
    belongs_to :resource, :class_name => 'Resource', :foreign_key => :forked_from_resource_id
    has_many :surveys, :class_name => 'Survey'
end
