class CreateSyncLogs < ActiveRecord::Migration
  def change
    create_table :sync_logs do |t|
      t.integer :num_deleted, null: false, default: 0
      t.integer :num_updated, null: false, default: 0
      t.timestamps null: false
    end
  end
end
