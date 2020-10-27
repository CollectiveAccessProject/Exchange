class AddLogIdToSyncLog < ActiveRecord::Migration[5.0]
def change
	add_column :sync_logs, :log_id, :int, null: false, default: 0
  end
end
