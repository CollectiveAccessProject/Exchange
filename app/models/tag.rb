class Tag < ActiveRecord::Base


    self.inheritance_column = :ruby_type
    belongs_to :user, :class_name => 'User', :foreign_key => :user_id
    belongs_to :vocabulary_item, :class_name => 'VocabularyItem', :foreign_key => :vocabulary_item_id
end
