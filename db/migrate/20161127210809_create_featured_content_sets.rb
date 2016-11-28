class CreateFeaturedContentSets < ActiveRecord::Migration
  def change
    create_table :featured_content_sets do |t|
      t.text :title, null: false, limit: 65535
      t.text :subtitle, null: false, limit: 65535
      t.text :body_text, null: false, limit: 65535
      t.string :slug, null: false, index: true
      t.references :user, index: true, null: true
      t.integer :rank, null: false, default: 0
      t.integer :access, null: false, default: 0, limit: 1

      t.timestamps null: false
    end
  end
end
