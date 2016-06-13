class CollectionContentRank < ActiveRecord::Migration
  def change
    add_column :resource_hierarchies, :rank, :integer
    remove_column :resources, :rank
  end
end
