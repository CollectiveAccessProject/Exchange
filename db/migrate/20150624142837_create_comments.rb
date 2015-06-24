class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :title, :limit => 50, :default => ''
      t.text :comment
      t.references :commentable, :polymorphic => true
      t.references :user
      t.string :role, :default => 'comments'

      t.string :name, null: true, limit: 255
      t.string :email, null: true, limit: 255
      t.text :media, null: true

      t.string :ip, null: false, index: true, limit: 15

      t.string :source_type, null:false, limit: 10
      t.string :source

      t.integer :access, null: false, default: 0, limit: 1

      t.timestamps null: false
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
