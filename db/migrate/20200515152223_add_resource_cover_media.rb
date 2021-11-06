class AddResourceCoverMedia < ActiveRecord::Migration
  def change
  	add_column :resources, :cover_uid,  :string
	add_column :resources, :cover_name, :string
  end
end
