class EnlargeUrl < ActiveRecord::Migration
  def change
  	remove_index :links, :name => "unique_link_per_resource"
    change_column :links, :url, :string, limit: 1024
  end
end
