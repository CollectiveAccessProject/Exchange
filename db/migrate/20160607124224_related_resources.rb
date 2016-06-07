class RelatedResources < ActiveRecord::Migration
  def change
    rename_column :related_resources, :from_resource_id, :resource_id
  end
end