class ChangeLog < ActiveRecord::Base
    self.table_name = 'change_log'


    belongs_to :user, :class_name => 'User', :foreign_key => :user_id
end
