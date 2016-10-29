class AddAncestryToVocabularyTerms < ActiveRecord::Migration
  def change
    add_column :vocabulary_terms, :ancestry, :string
    add_index :vocabulary_terms, :ancestry
  end
end
