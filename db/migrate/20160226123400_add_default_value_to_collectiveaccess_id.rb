class AddDefaultValueToCollectiveaccessId < ActiveRecord::Migration
  def up
    change_column :resources, :collectiveaccess_id, :string, :default => ''
  end

  def down
    change_column :resources, :collectiveaccess_id, :string, :default => nil
  end
end
