class CreateResourcesGroups < ActiveRecord::Migration
  def change
    create_table :resources_groups do |t|
      t.references :resource
      t.references :group
      t.integer :access, limit: 1
    end
  end
end
