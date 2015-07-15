class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, index: true, null: false, limit: 100
      t.string :slug, index: true, null: false, limit: 100
      t.text :description, null: true
      t.integer :type, limit: 1

      t.timestamps null: false
    end
  end
end
