class CreateResourcesVocabularyTerms < ActiveRecord::Migration
  def change
    create_table :resources_vocabulary_terms do |t|
      t.references :resource, index: true, null: false
      t.references :vocabulary_term, index:true, null: false

      t.timestamps null: false
    end
  end
end
