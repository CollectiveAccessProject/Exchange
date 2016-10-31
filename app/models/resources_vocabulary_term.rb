class ResourcesVocabularyTerm < ActiveRecord::Base
  belongs_to :resources, class_name: 'Resource'
  belongs_to :vocabulary_terms, class_name: 'VocabularyTerm', foreign_key: 'vocabulary_term_id'
end
