class CollectionObjectsAsMedia < ActiveRecord::Migration
  def change
    create_table :collectionobject_links do |t|
      t.integer :resource_id, null: false, index: true
      t.string :original_link, null: false
      t.timestamps null: false
    end
  end
end