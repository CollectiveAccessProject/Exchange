class AddResourceCoverMedia < ActiveRecord::Migration[5.0]
  def change
  	add_column :resources, :cover_uid,  :string
	add_column :resources, :cover_name, :string
  end
end
