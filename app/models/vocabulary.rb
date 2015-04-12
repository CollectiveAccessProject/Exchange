class Vocabulary < ActiveRecord::Base



    has_many :vocabulary_items, :class_name => 'VocabularyItem'
end
