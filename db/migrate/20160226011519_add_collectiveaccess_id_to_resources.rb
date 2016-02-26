class AddCollectiveaccessIdToResources < ActiveRecord::Migration
  def change
    add_column :resources, :collectiveaccess_id, :string
  end
end
