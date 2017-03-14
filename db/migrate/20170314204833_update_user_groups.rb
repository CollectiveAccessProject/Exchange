class UpdateUserGroups < ActiveRecord::Migration
  def change
    rename_column :user_groups, :type, :access_type
  end
end
