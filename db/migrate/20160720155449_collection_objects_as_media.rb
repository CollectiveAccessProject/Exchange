class CollectionObjectsAsMedia < ActiveRecord::Migration
  def change
    create_table :collectionobject_links do |t|
      t.integer :resource_id, null: false, index: true

      t.timestamps null: false
    end
  end
end
