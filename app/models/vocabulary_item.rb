class VocabularyItem < ActiveRecord::Base
    self.table_name = 'vocabulary_item'


    has_many :tags, :class_name => 'Tag'
    belongs_to :vocabulary, :class_name => 'Vocabulary', :foreign_key => :vocabulary_id
    has_many :vocabulary_item_alternates, :class_name => 'VocabularyItemAlternate'
    has_many :vocabulary_item_hierarchies, :class_name => 'VocabularyItemHierarchy'
    has_many :vocabulary_item_hierarchies, :class_name => 'VocabularyItemHierarchy'
end
