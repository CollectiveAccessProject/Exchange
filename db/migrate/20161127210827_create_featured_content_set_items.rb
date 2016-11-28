class CreateFeaturedContentSetItems < ActiveRecord::Migration
  def change
    create_table :featured_content_set_items do |t|
      t.text :title, null: false, limit: 65535
      t.text :subtitle, null: false, limit: 65535
      t.references :resource, index: true, null: false
      t.references :media_files, index:true, null: true
      t.integer :rank, null: false, default: 0

      t.timestamps null: false
    end
  end
end
