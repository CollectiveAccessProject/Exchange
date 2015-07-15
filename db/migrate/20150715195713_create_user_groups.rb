class CreateUserGroups < ActiveRecord::Migration
  def change
    create_table :user_groups do |t|
      t.integer :type, null: true, limit: 1

      t.timestamps null: false
    end
  end
end
