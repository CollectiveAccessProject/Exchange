class CreateFeaturedContentSetItems < ActiveRecord::Migration
  def change
    create_table :featured_content_set_items do |t|
      t.text :title, null: false, limit: 65535
      t.text :subtitle, null: false, limit: 65535
      t.integer :featured_content_set_id, null: false, index: true
      t.references :resource, index: true, null: false
      t.integer :rank, null: false, default: 0

      t.timestamps null: false
    end
    add_foreign_key :featured_content_set_items, :featured_content_sets, column: :featured_content_set_id
  end
end
