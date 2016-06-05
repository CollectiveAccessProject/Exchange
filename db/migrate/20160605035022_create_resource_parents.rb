class CreateResourceParents < ActiveRecord::Migration
  def change
    create_table :resource_parents do |t|
      t.integer :parent_resource_id, null: false
      t.integer :child_resource_id, null: false

      t.timestamps null: false
    end
  end
end