class CreateRelatedResources < ActiveRecord::Migration
  def change
    create_table :related_resources do |t|
      t.text :caption, null: false, limit: 65535

      t.integer :from_resource_id, null: false
      t.integer :to_resource_id, null: false
      t.integer :type, null: false, limit: 1

      t.timestamps null: false
    end
  end
end
