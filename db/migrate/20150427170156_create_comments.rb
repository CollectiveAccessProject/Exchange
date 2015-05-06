class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :commentable_id, index: true, null: false
      t.string  :commentable_type, index: true, null: false

      t.text :commment, null: false, limit: 65535
      t.string :name, null: true, limit: 255
      t.string :email, null: true, limit: 255
      t.text :media, null: true

      t.references :users, null: false, index: true

      t.string :ip, null: false, index: true, limit: 15

      t.string :source_type, null:false, limit: 10
      t.string :source

      t.integer :access, null: false, default: 0, limit: 1

      t.timestamps null: false
    end
  end
end
