class ChangeLog < ActiveRecord::Base
  belongs_to :change_log, polymorphic: true
end
