class Link < ActiveRecord::Base



    belongs_to :resource, :class_name => 'Resource', :foreign_key => :resource_id
end
