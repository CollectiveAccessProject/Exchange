class CreateVocabularyTermSynonyms < ActiveRecord::Migration
  def change
    create_table :vocabulary_term_synonyms do |t|
      t.string :synonym, null: false, limit: 255
      t.references :vocabulary_term, index: true, null: false     # reference to primary term
      t.text :description, null: false, limit: 65535
      t.string :reference_url, null: false, limit: 255

      t.integer :lock_version, null: false, default: 0

      t.timestamps null: false
    end
  end
end
