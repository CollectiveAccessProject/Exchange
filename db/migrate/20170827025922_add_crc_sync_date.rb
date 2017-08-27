class AddCrcSyncDate < ActiveRecord::Migration
  def change
    add_column :resources, :crc_sync_date, :integer, null: true
  end
end
