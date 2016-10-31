class VocabularyTerm < ActiveRecord::Base
  has_ancestry

  has_many :vocabulary_term_synonyms
  has_many :resources_vocabulary_terms
  has_many :resources, through: :resources_vocabulary_terms
end
