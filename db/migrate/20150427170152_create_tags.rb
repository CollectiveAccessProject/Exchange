class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :taggable_id, index: true, null: false
      t.string  :taggable_type, index: true, null: false

      t.integer :type, index:true, null: false, limit: 1
      t.string :tag, index: true, null: false, limit: 255
      t.string :tag_sort, index: true, null: false, limit: 255

      t.references :users, null: false, index: true

      t.string :ip, null: false, index: true, limit: 15

      t.string :source_type, null:false, limit: 10
      t.string :source

      t.integer :access, null: false, default: 0, limit: 1

      t.timestamps null: false
    end
  end
end
