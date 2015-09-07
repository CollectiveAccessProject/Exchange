class DropChangeLog < ActiveRecord::Migration
  def change
    drop_table :change_logs
  end
end
