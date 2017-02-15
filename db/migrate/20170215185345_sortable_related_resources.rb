class SortableRelatedResources < ActiveRecord::Migration
  def change
    add_column :related_resources, :rank, :integer
  end
end
