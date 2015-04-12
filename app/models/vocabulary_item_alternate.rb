class VocabularyItemAlternate < ActiveRecord::Base



    belongs_to :vocabulary_item, :class_name => 'VocabularyItem', :foreign_key => :vocabulary_item_id
end
