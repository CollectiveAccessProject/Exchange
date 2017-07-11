class AddIsDisabledColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_disabled, :tinyint, unsigned: true, null: false
  end
end
