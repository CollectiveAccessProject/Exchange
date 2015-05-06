class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :slug,              null: false, index: true, default: ""
      t.references :users, index: true, null: false     # reference to user creating resource
      t.references :parent, index: true, null: true     # reference to parent resource

      t.integer :resource_type, index: true, null: false, limit: 1
      t.text :title, null: false, limit: 65535
      t.text :subtitle, null: false, limit: 65535

      t.string :source_type, null:false, limit: 10
      t.string :source

      t.integer :copyright_license, null: false, default: 0, limit: 1
      t.string :copyright_notes, null: false
      t.integer :rank, null: false, default: 0
      t.integer :access, null: false, default: 0, limit: 1
      t.references :forked_from_resource, index: true, null: true

      t.integer :transition, null: false, limit: 1
      t.integer :lock_version, null: false
      t.timestamps null: false
    end
  end
end
