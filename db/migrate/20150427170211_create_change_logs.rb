class CreateChangeLogs < ActiveRecord::Migration
  def change
    create_table :change_logs do |t|
      t.integer :change_log_id, index: true, null: false
      t.string  :change_log_type, index: true, null: false

      t.string :field_name, limit: 100, null: true, index: true
      t.string :event, limit: 4, null: false
      t.text :value, null: false
      t.references :users, index: true, null: false

      t.timestamps null: false
    end
  end
end
