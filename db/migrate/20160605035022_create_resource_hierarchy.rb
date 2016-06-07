class CreateResourceHierarchy < ActiveRecord::Migration
  def change
    create_table :resource_hierarchies do |t|
      t.integer :resource_id, null: false
      t.integer :child_resource_id, null: false

      t.timestamps null: false
    end
  end
end