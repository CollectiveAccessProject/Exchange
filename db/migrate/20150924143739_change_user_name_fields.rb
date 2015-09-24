class ChangeUserNameFields < ActiveRecord::Migration
  def change
    remove_column :users, :first_name
    remove_column :users, :last_name

    add_column :users, :name, :string, null: false
  end
end
