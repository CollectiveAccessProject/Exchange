class UserFeedback < ActiveRecord::Base
    self.table_name = 'user_feedback'


    belongs_to :user, :class_name => 'User', :foreign_key => :user_id
end
