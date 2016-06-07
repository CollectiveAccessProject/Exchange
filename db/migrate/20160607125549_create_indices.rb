class CreateIndices < ActiveRecord::Migration
  def change
    create_table :indices do |t|
      add_foreign_key :related_resources, :resources, column: :resource_id

      add_foreign_key :resource_hierarchies, :resources, column: :resource_id
      add_foreign_key :resource_hierarchies, :resources, column: :child_resource_id
    end
  end
end
