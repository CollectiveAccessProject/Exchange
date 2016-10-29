class VocabularyTerm < ActiveRecord::Base
  has_ancestry

  has_many :vocabulary_term_synonyms
end
