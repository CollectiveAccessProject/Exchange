class CreateVocabularyTerms < ActiveRecord::Migration
  def change
    create_table :vocabulary_terms do |t|
      t.string :term, null: false, limit: 255
      t.text :description, null: false, limit: 65535
      t.string :reference_url, null: false, limit: 255

      t.integer :lock_version, null: false, default: 0

      t.timestamps null: false
    end
  end
end
