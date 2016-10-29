class ResourcesVocabularyTerm < ActiveRecord::Base
  belongs_to :resource
  belongs_to :vocabulary_term

end
