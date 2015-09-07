class AddForeignKeys < ActiveRecord::Migration
  def change
    add_index :media_files, :resource_id
    add_index :related_resources, [:from_resource_id, :to_resource_id]

    add_reference :user_groups, :user, index: true
    add_reference :user_groups, :group, index: true
  end
end
