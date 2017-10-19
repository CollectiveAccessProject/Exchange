class AddGroupCode < ActiveRecord::Migration
  def change
	add_column :groups, :group_code, :string
  end
end
