class RemoveRelatedResourceType < ActiveRecord::Migration
  def change
    remove_column :related_resources, :type
  end
end
