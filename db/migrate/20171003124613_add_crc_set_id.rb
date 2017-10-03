class AddCrcSetId < ActiveRecord::Migration
  def change
	add_column :resources, :crc_set_id, :integer, null: true
  end
end
