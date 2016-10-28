class AddRoleField < ActiveRecord::Migration
  def change
    add_column :resources, :role, :string, limit: 1024
  end
end
