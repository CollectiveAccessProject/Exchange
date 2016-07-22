class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :resource_id, null: false, index: true
      t.integer :user_id, null: false, index: true
      t.timestamps null: false
    end
  end
end
