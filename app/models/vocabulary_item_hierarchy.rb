class VocabularyItemHierarchy < ActiveRecord::Base
    self.table_name = 'vocabulary_item_hierarchy'


    belongs_to :vocabulary_item, :class_name => 'VocabularyItem', :foreign_key => :parent_id
    belongs_to :vocabulary_item, :class_name => 'VocabularyItem', :foreign_key => :child_id
end
