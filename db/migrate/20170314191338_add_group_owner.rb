class AddGroupOwner < ActiveRecord::Migration
  def change
    add_column :groups, :user_id, :integer, null: true, index: true, references: "users"
    rename_column :groups, :type, :group_type
  end
end
